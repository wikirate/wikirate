card_accessor :value, type: :phrase

def year
  cardname.right
end

def metric_name
  cardname.left_name.left
end

def company_name
  cardname.left_name.right
end

def metric_card
  Card.fetch metric_name
end

def company_card
  Card.fetch company_name
end

def source_subcards new_source_card
  [new_source_card.subfield(:file), new_source_card.subfield(:text),
   new_source_card.subfield(:wikirate_link)]
end

def source_in_request?
  sub_source_card = subfield('source')
  return false if sub_source_card.nil? ||
                  sub_source_card.subcard('new_source').nil?
  new_source_card = sub_source_card.subcard('new_source')
  source_subcard_exist?(new_source_card)
end

def source_subcard_exist? new_source_card
  file_card, text_card, link_card = source_subcards new_source_card
  (file_card && file_card.attachment.present?) ||
    (text_card && text_card.content.present?) ||
    (link_card && link_card.content.present?)
end

# TODO: add #subfield_present? method to subcard API
def subfield_exist? field_name
  subfield_card = subfield(field_name)
  !subfield_card.nil? && subfield_card.content.present?
end

event :set_metric_value_name,
      before: :set_autoname, when: proc { |c| c.cardname.parts.size < 4 } do
  self.name = %w(metric company year).map do |name|
    content = remove_subfield(name).content
    content.gsub('[[', '').gsub(']]', '')
  end.join '+'
end

event :validate_metric_value_fields, before: :set_metric_value_name do
  %w(metric company year value).each do |name|
    unless subfield_exist?(name)
      errors.add :field, "Missing #{name}. Please check before submit."
    end
  end
end

def number? str
  true if Float(str)
rescue
  false
end

event :validate_value_type, :validate, on: :save do
  # check if the value fit the value type of metric
  if (value_type = Card["#{metric_card.name}+value type"])
    value = subfield(:value).content
    case value_type.item_names[0]
    when 'Number', 'Monetary'
      unless number?(value)
        errors.add :value, 'Only numeric content is valid for this metric.'
      end
    when 'Category'
      # check if the value exist in options
      if !(option_card = Card["#{metric_card.name}+value options"]) ||
         !option_card.item_names(contenxt: :raw).include?(value)
        url = "/#{option_card.cardname.url_key}?view=edit"
        anchor =
          <<-HTML
            <a href='#{url}' target="_blank">add options</a>
          HTML
        errors.add :options, "Please #{anchor} before adding metric value."
      end
    end
  end
end

event :create_source_for_metric_value, :validate, on: :create do
  create_source
end

event :create_source_for_updating_metric_value,
      :prepare_to_store,
      on: :update, when: proc { |c| c.source_in_request? } do
  create_source
end

def create_source
  value_card = remove_subfield('value')
  if (source_list = subfield('source'))
    clear_subcards
    source_card = get_source_card source_list
    if !source_card
      errors.add :source, "#{source_list.content} does not exist."
    elsif source_card.errors.empty?
      fill_subcards value_card, source_card
    else
      fill_errors source_card
    end
  else
    errors.add :source, 'does not exist.'
  end
end

def clone_subcards_to_hash subcards
  source_subcards = {}
  subcards.subcards.each_with_key do |subcard, _key|
    subcard_key = subcard.tag.key
    if subcard_key == 'file'
      source_subcards["+#{subcard_key}"] = { file: subcard.file.file,
                                             type_id: subcard.type_id }
    else
      source_subcards["+#{subcard_key}"] = { content: subcard.content,
                                             type_id: subcard.type_id }
    end
  end
  source_subcards
end

def get_source_card source_list
  with_sourcebox do
    if (new_source_card = source_list.subcard('new_source'))
      if (url = new_source_card.subfield(:wikirate_link)) &&
         (source_card = find_duplicate_source(url.content))
        source_card
      else
        add_source_subcard new_source_card
      end
    else
      Card[source_list.content]
    end
  end
end

def add_source_subcard new_source_card
  source_subcards = clone_subcards_to_hash new_source_card
  source_card = add_subcard '', type_id: SourceID,
                                subcards: source_subcards
  source_card.director.catch_up_to_stage :prepare_to_store
  source_card
end

def find_duplicate_source url
  (link_card = Card::Set::Self::Source.find_duplicates(url).first) &&
    link_card.left
end

def with_sourcebox
  Env.params[:sourcebox] = 'true'
  result = yield
  Env.params[:sourcebox] = nil
  result
end

def fill_errors source_card
  source_card.errors.each do |key, value|
    errors.add key, value
  end
end

def fill_subcards metric_value, source_card
  add_subcard '+value', content: metric_value.content, type_id: PhraseID
  add_subcard '+source', content: "[[#{source_card.name}]]",
                         type_id: PointerID
end

format :html do
  def get_structure args
    if args[:company]
      'metric company add value'
    elsif args[:source]
      'metric_source_add_value'
    elsif args[:metric]
      'metric add value'
    else
      'default add metric value'
    end
  end

  def set_hidden_args args
    if !args[:source]
      view = (args[:metric] || args[:company]) ? :titled : :open
      args[:hidden] = {
        :success => { id: '_self', soft_redirect: true, view: view },
        'card[subcards][+metric][content]' => args[:metric]
      }
    else
      args[:hidden] = {}
    end
  end

  def default_new_args args
    set_hidden_args args
    if args[:company]
      args[:hidden]['card[subcards][+company][content]'] = args[:company]
    end
    if args[:source]
      args[:hidden]['card[subcards][+source][content]'] = args[:source]
    end
    args[:title] = "Add new value for #{args[:metric]}" if args[:metric]
    args[:structure] = get_structure args
    super(args)
  end

  def legend args
    subformat(card.metric_card)._render_legend args
  end

  def currency
    return unless (value_type = Card["#{card.metric_card.name}+value type"])
    return unless value_type.item_names[0] == 'Monetary' &&
                  (currency = Card["#{card.metric_card.name}+currency"])
    currency.content
    
  end

  view :concise do |args|
    %(
      <span class="metric-year">
        #{card.year} =
      </span>
      <span class="metric-unit">
        #{currency}
      </span>
      #{_render_modal_details(args)}
      <span class="metric-unit">
        #{legend(args)}
      </span>
    )
  end

  view :modal_details do |args|
    
    show_value =
      if (value_type = card.metric_card.fetch trait: :value_type)
        if %w(Number Monetary).include? value_type.item_names[0]
          big_number = BigDecimal.new(card.value)
          number_to_human(big_number)
        else
          card.value
        end
      end
    modal_link = subformat(card)._render_modal_link(
      args.merge(
        text: show_value,
        path_opts: { slot: { show: :menu, optional_horizontal_menu: :hide } },
        html_args: {
          'data-complete-number': card.value,
          'data-tooltip': 'true',
          'data-placement': 'top',
          'title': card.value
        }
      )
    ) # ,:html_args=>{:class=>"td year"}))
    %(
      <span class="metric-value">
        #{modal_link}
      </span>
    )
  end

  view :timeline_data do |args|
    year = content_tag(:span, card.cardname.right, class: 'metric-year')
    # value_card = card.fetch(trait: :value)
    value = content_tag(:span, currency, class: 'metric-unit')
    value << _render_modal_details(args).html_safe
    value << content_tag(:span, legend(args), class: 'metric-unit')

    line   =  content_tag(:div, '', class: 'timeline-dot')
    line << content_tag(:div, '', class: 'timeline-line') if args[:connect]

    credit = wrap_with :div, class: 'td credit' do
      [
        nest(card, view: :core, structure: 'creator credit'),
        _optional_render(:source_link, args, :hide)
      ]
    end

    wrap_with :div, class: 'timeline-row' do
      [
        line,
        content_tag(:div, year.html_safe,  class: 'td year'),
        content_tag(:div, value.html_safe, class: 'td value'),
        credit

      ]
    end
  end

  view :source_link do |_args|
    if (source_card = card.fetch(trait: :source))
      source_card.item_cards.map do |i_card|
        subformat(i_card).render_original_icon_link
      end.join "\n"
    else
      ''
    end
  end
end
