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

def year_card
  Card.fetch year
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

def researched?
  (mc = metric_card) && mc.researched?
end

def scored?
  (mc = metric_card) && mc.scored?
end


def valid_value_name?
  cardname.parts.size >= 3 &&
    metric_card && metric_card.type_id == MetricID &&
    company_card && company_card.type_id == WikirateCompanyID &&
    year_card && year_card.type_id == YearID
end

# TODO: add #subfield_present? method to subcard API
def subfield_exist? field_name
  subfield_card = subfield(field_name)
  !subfield_card.nil? && subfield_card.content.present?
end

event :set_metric_value_name,
      before: :set_autoname, when: proc { |c| c.cardname.parts.size < 4 } do
  return if valid_value_name?
  self.name = %w(metric company year).map do |part|
    name_part = remove_subfield(part)
    unless name_part
      errors.add :name, "missing #{part} part"
      next
    end
    name_part.content.gsub('[[', '').gsub(']]', '')
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
  if metric_card && (value_type = Card["#{metric_card.name}+value type"])
    value = subfield(:value).content
    return if value.casecmp('unknown') == 0
    case value_type.item_names[0]
    when 'Number', 'Money'
      unless number?(value)
        errors.add :value, 'Only numeric content is valid for this metric.'
      end
    when 'Category'
      # check if the value exist in options
      if !(option_card = Card["#{metric_card.name}+value options"]) ||
         !option_card.item_names.include?(value)
        url = "/#{option_card.cardname.url_key}?view=edit"
        anchor = %(<a href='#{url}' target="_blank">add options</a>)
        errors.add :options, "Please #{anchor} before adding metric value."
      end
    end
  end
end

event :create_source_for_metric_value, :validate,
      on: :create, when: proc { |c| c.researched? || c.source_in_request? }  do
  create_source
end

event :create_source_for_updating_metric_value,
      :prepare_to_store,
      on: :update, when: proc { |c| c.source_in_request? } do
  create_source
end

def create_source
  value_card = detach_subfield('value')
  if (source_list = detach_subfield('source'))
    source_names = process_sources source_list
    fill_subcards value_card, source_names if errors.empty?
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

def find_or_create new_source_card
  with_sourcebox do
    if (url = new_source_card.subfield(:wikirate_link)) &&
       (source_card = find_duplicate_source(url.content))
      source_card
    else
     add_source_subcard new_source_card
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

def process_sources source_list
  source_names = source_list.item_names
  source_names.each do |source_name|
    next if  Card.exists? source_name
    errors.add :source, "#{source_name} does not exist."
  end

  if (new_source_subcard = source_list.detach_subcard('new_source'))
    source_card = find_or_create new_source_subcard
    if source_card.errors.present?
      fill_errors source_card
    end
    source_names << source_card.name
  end
  source_names
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

def fill_subcards metric_value, source_names
  add_subfield :value, content: metric_value.content, type_id: PhraseID
  add_subfield :source, content: source_names.to_pointer_content,
                        type_id: PointerID
end

format :html do
  view :open_content do |args|
    _render_timeline_data args
  end

  view :new do |args|
    # return super(args)
    return _render_no_frame_form args if Env.params[:noframe]
    # return super(args) if args[:source] || args[:metric] || args[:company]
    return super(args) if args[:source] || args[:company]
    @form_root = true

    frame args do # no form!
      [
        _optional_render(:content_formgroup,
                         args.merge(metric_value_landing: true))
        #  _optional_render(:button_formgroup, button_args)
      ]
    end
  end

  def edit_slot args
    args.merge! edit_fields: { '+value' => {} } unless special_editor? args
    super(args)
  end

  def special_editor? args
    (args[:company] && args[:metric]) || args[:metric_value_landing]
  end

  view :editor do |args|
    if args[:company] && args[:metric]
      _render_metric_company_add_value_editor args
    # elsif args[:source] || args[:metric]
    #   _render_add_value_editor args
    elsif args[:metric_value_landing]
      _render_metric_value_landing args
    else
      super args
    end
  end

  view :metric_value_landing do |args|
    metric_field = _render_metric_field(args)
    render_haml source_container: _render_source_container,
                metric_field: metric_field do
      <<-HAML
.col-md-6.border-right.panel-default
  -# %h4
  -# Company
  %hr
    = field_nest :wikirate_company, title: 'Company'
  -# %h4
    -# Metric
  %hr
    = metric_field
= source_container
      HAML
    end
  end

  view :metric_field do |args|
    metric = args[:metric]
    metric_field =
      Card.fetch(card.cardname.field(:metric), new: { content: metric })
    render_haml metric: metric,
                source_container: _render_source_container,
                metric_field: metric_field do
      <<-HAML
= nest metric_field, title: 'Metric'
.col-md-6.col-centered.text-center
  %a.btn.btn-primary._new_value_next
    Next
      HAML
    end
  end

  view :source_container do |_args|
    render_haml do
      <<-HAML
.col-md-6.nopadding.panel-default
  .col-md-6.col-centered.text-center.light-grey-color-2
    %p
      Source Preview Container
    %p
      Please select a company and metric to add new sources and metric values.
      HAML
    end
  end

  view :no_frame_form do |args|
    form_opts = args[:form_opts] ? args.delete(:form_opts) : {}
    form_opts[:hidden] = args.delete(:hidden)
    form_opts['main-success'] = 'REDIRECT'
    card_form :create, form_opts do
      output [
        _optional_render(:name_formgroup, args),
        _optional_render(:type_formgroup, args),
        _optional_render(:content_formgroup, args),
        _optional_render(:button_formgroup, args)
      ]
    end
  end

  view :add_value_editor do |_args|
    render_haml do
      <<-HAML
= field_nest :metric, title: 'Metric' unless args[:metric]
= field_nest :wikirate_company, title: 'Company'
.fluid-container
  .row
    .col-xs-2
      = field_nest :year, title: 'Year'
    .col-xs-10
      = field_nest :value, title: 'Value'
    end
= field_nest :wikirate_source, title: 'Source' if args[:metric]
      HAML
    end
  end

  view :metric_company_add_value_editor do |_args|
    render_haml do
      <<-HAML
.td.year
  = field_nest :year, title: 'Year'
.td.value
  %span.metric-value
    = field_nest :value, title: 'Value'
  = field_nest :discussion, title: 'Comment'
  %h5
    Choose Sources or
    %a.btn.btn-sm.btn-default._add_new_source
      %small
        %span.icon.icon-wikirate-logo-o.fa-lg
        Add a new Source
  .relevant-sources
    None
  %h5
    Cited Sources
  .card-editor
    = hidden_field_tag 'card[subcards][+source][content]', nil, class: 'card-content'
    .cited-sources.pointer-list-ul
      None
  HAML
    end
  end

  def set_hidden_args args
    if !args[:source]
      # TODO: add appropriate view to the following condition.
      # view = (args[:metric] || args[:company]) ? :timeline_data : :timeline_data
      args[:hidden] = {
        :success => { id: '_self', soft_redirect: true, view: :timeline_data },
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
    super(args)
  end

  # def edit_slot args
  #   super args.merge(core_edit: true)
  # end

  def legend args
    subformat(card.metric_card)._render_legend args
  end

  def currency
    return unless (value_type = Card["#{card.metric_card.name}+value type"])
    return unless value_type.item_names[0] == 'Money' &&
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

  def grade
    return unless value = (card.value && card.value.to_i)
    case value
    when 0, 1, 2, 3 then :low
    when 4, 5, 6, 7 then :middle
    when 8, 9, 10 then :high
    end
  end

  view :modal_details do |args|
    span_args = { class: 'metric-value' }
    add_class span_args, grade if card.scored?
    show_value =
      if (value_type = card.metric_card.fetch trait: :value_type) &&
         %w(Number Money).include?(value_type.item_names[0])
        big_number = BigDecimal.new(card.value)
        number_to_human(big_number)
      else
        card.value

      end

    wrap_with :span, span_args do
      subformat(card)._render_modal_link(
        args.merge(
          text: show_value,
          path_opts: { slot: { show: :menu, optional_horizontal_menu: :hide } },
          html_args: {
            'data-complete-number' => card.value,
            'data-tooltip' => 'true',
            'data-placement' => 'top',
            'title' => card.value
          }
        )
      ) # ,:html_args=>{:class=>"td year"}))
    end
  end

  view :value_link do |args|
    url = "/#{card.cardname.url_key}"
    link = link_to card.value, url, target: '_blank'
    content_tag(:span, link.html_safe, class: 'metric-value')
  end

  view :timeline_data do |args|
    # container elements
    value = content_tag(:span, currency, class: 'metric-unit')
    value << _render_value_link(args)
    value << content_tag(:span, legend(args), class: 'metric-unit')
    value << _render_value_details_toggle
    value << _render_value_details(args)

    # stitch together
    wrap_with :div, class: 'timeline-row' do
      [
        _render_year,
        content_tag(:div, value.html_safe, class: 'td value')
      ]
    end
  end

  view :year do
    year = content_tag(:span, card.cardname.right)
    year << content_tag(:div, '', class: 'timeline-dot')
    content_tag(:div, year.html_safe, class: 'td year')
  end

  view :value_details do |args|
    wrap_with :div, class: 'metric-value-details collapse' do
      [
        _optional_render(:credit_name, args, :show),
        content_tag(:div, _render_comments(args), class: 'comments-div'),
        content_tag(:div, _render_sources, class: 'cited-sources')
      ]
    end
  end

  view :value_details_toggle do
    content_tag(:i, '', class: 'fa fa-caret-right '\
                                'fa-lg margin-left-10 '\
                                'btn btn-default btn-sm ',
                        data: { toggle: 'collapse-next',
                                parent: '.value',
                                collapse: '.metric-value-details'
                              }
               )
  end

  view :sources do
    heading = content_tag(:h5, 'Cited')
    sources = card.fetch trait: :source
    heading << subformat(sources).render_core(item: :cited).html_safe
  end

  view :comments do |args|
    disc_card = card.fetch trait: :discussion, new: {}
    comments = disc_card.real? ? subformat(disc_card).render_core : ''
    comments += subformat(disc_card).render_comment_box
    wrap do
      [
        content_tag(:h5, 'Discussion'),
        comments.html_safe
      ]
    end
  end

  view :credit_name do |args|
    wrap_with :div, class: 'credit' do
      [
        nest(card, view: :core, structure: 'creator credit'),
        _optional_render(:source_link, args, :hide)
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
