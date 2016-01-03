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

def source_exist?
  sub_source_card = subfield('source')
  return false if sub_source_card.nil?
  new_source_card = sub_source_card.subcard('new_source')
  file_card = new_source_card.subfield :file
  text_card = new_source_card.subfield :text
  link_card = new_source_card.subfield :wikirate_link

  (file_card && file_card.attachment.present?) ||
    (text_card && text_card.content.present?) ||
    (link_card && link_card.content.present?)
end

def researched?
  defined?(Card::Set::MetricType::Researched) &&
    set_modules.include?(Card::Set::MetricType::Researched)
end

event :set_metric_value_name,
      before: :set_autoname, when: proc { |c| c.cardname.parts.size < 4 } do
  self.name = ['metric', 'company', 'year'].map do |name|
    content = remove_subfield(name).content
    content.gsub('[[', '').gsub(']]', '')
  end.join '+'
end

event :create_source_for_metric_value,
      before: :process_subcards, on: :create,
      when: proc { |c| c.researched? }  do
  create_source
end

event :create_source_for_updating_metric_value,
      before: :process_subcards, on: :update,
      when: proc { |c| c.source_exist? && c.researched? } do
  create_source
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

def get_source_card sub_source_card
  Env.params[:sourcebox] = 'true'
  card =
    if (new_source_card = sub_source_card.subcard('new_source'))
      new_source_card.approve_subcards
      source_subcards = clone_subcards_to_hash new_source_card
      Card.create type_id: SourceID, subcards: source_subcards
    else
      Card[sub_source_card.content]
    end
  Env.params[:sourcebox] = nil
  card
end

def create_source
  metric_value = remove_subfield 'value'
  if (sub_source_card = subfield('source'))
    source_card = get_source_card sub_source_card
    clear_subcards
    if !source_card
      errors.add :source, "#{sub_source_card.content} does not exist."
    elsif source_card.errors.empty?
      add_subcard '+value', content: metric_value.content, type_id: PhraseID
      add_subcard '+source', content: "[[#{source_card.name}]]",
                             type_id: PointerID
    else
      source_card.errors.each do |key, value|
        errors.add key, value
      end
    end
  else
    errors.add :source, 'does not exist.'
  end
end

format :html do
  def default_new_args args
    if !args[:source]
      args[:hidden] = {
        :success => { id: '_self', soft_redirect: true, view: :titled },
        'card[subcards][+metric][content]' => args[:metric]
      }
    else
      args[:hidden] = {}
    end

    if args[:company]
      args[:hidden]['card[subcards][+company][content]'] = args[:company]
    end
    if args[:source]
      args[:hidden]['card[subcards][+source][content]'] = args[:source]
    end
    args[:structure] =
      if args[:company]
        'metric company add value'
      elsif args[:source]
        'metric_source_add_value'
      else
        'metric add value'
      end
    super(args)
  end

  def legend args
    subformat(card.metric_card)._render_legend args
  end

  view :concise do |args|
    %{
      <span class="metric-year">
        #{card.year} =
      </span>
      #{_render_modal_details(args)}
      <span class="metric-unit">
        #{legend(args)}
      </span>
    }
  end

  view :modal_details do |args|
    modal_link = subformat(card)._render_modal_link(
      args.merge(
        text: card.value,
        path_opts: { slot: { show: :menu, optional_horizontal_menu: :hide } }
      )
    ) # ,:html_args=>{:class=>"td year"}))
    %{
      <span class="metric-value">
        #{modal_link}
      </span>
    }
  end

  view :timeline_data do |args|
    year  =  content_tag(:span, card.cardname.right, class: 'metric-year')
    # value_card = card.fetch(trait: :value)
    value =  _render_modal_details(args)
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
