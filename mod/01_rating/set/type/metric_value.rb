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

def value_type
  if (value_type_card = Card.fetch "#{metric_card.name}+value type") &&
     !value_type_card.content.empty?
    return value_type_card.item_names[0]
  end
  nil
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
        errors.add :value, "Please #{anchor} before adding metric value."
      end
    end
  end
end

def report_type
  metric_card.fetch trait: :report_type
end

def add_report_type source_name
  if report_type
    report_names = report_type.item_names
    source_card = Card.fetch(source_name).fetch trait: :report_type, new: {}
    report_names.each do |report_name|
      source_card.add_item! report_name
    end
  end
end

def add_company source_name
  source_card = Card.fetch(source_name).fetch trait: :wikirate_company, new: {}
  source_card.add_item! company_name
end

event :process_sources, :prepare_to_validate,
      on: :save, when: proc { |c| c.researched? } do
  if (sources = subfield(:source))
    sources.item_names.each do |source_name|
      if Card.exists? source_name
        add_report_type source_name
        add_company source_name
      else
        errors.add :source, "#{source_name} does not exist."
      end
    end
  else
    errors.add :source, 'does not exist.'
  end
end

format :html do
  view :open_content do |args|
    _render_timeline_data args
  end

  view :new do |args|
    return _render_no_frame_form args if Env.params[:noframe] == 'true'
    @form_root = true
    frame args do # no form!
      [
        _optional_render(:content_formgroup,
                         args.merge(metric_value_landing: true))
      ]
    end
  end

  def edit_slot args
    args[:edit_fields] = { '+value' => {} } unless special_editor? args
    super(args)
  end

  def special_editor? args
    (args[:company] && args[:metric]) || args[:metric_value_landing]
  end

  view :editor do |args|
    if args[:company] && args[:metric]
      _render_metric_value_editor args
    elsif args[:metric_value_landing]
      _render_metric_value_landing args
    else
      super args
    end
  end

  view :metric_value_landing do |args|
    render_haml source_container: _render_source_container,
                metric_field: _render_metric_field(args),
                hidden_source_field: _render_hidden_source_field(args) do
      <<-HAML
.col-md-6.border-right.panel-default
  = hidden_source_field
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

  view :hidden_source_field do |args|
    if (source = args[:source])
      hidden_field 'hidden_source', value: source
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

  # TODO: please verify if this view used anywhere
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

  view :metric_value_editor do |args|
    render_haml relevant_sources: _render_relevant_sources(args),
                cited_sources: _render_cited_sources do
      <<-HAML
.td.year
  = field_nest :year, title: 'Year'
.td.value
  %span.metric-value
    = field_nest :value, title: 'Value'
  %h5
    Choose Sources or
    %a.btn.btn-sm.btn-default._add_new_source
      %small
        %span.icon.icon-wikirate-logo-o.fa-lg
        Add a new source
  = relevant_sources
  = cited_sources
  = field_nest :discussion, title: 'Comment'
      HAML
    end
  end

  def find_potential_sources company, metric
    Card.search(
      type_id: Card::SourceID,
      right_plus: [['company', { refer_to: company }],
                   ['report_type', {
                     refer_to: {
                       referred_to_by: metric + '+report_type' } }]]
    )
  end

  view :relevant_sources do |args|
    sources = find_potential_sources args[:company], args[:metric]
    if (source_name = args[:source]) && (source_card = Card[source_name])
      sources.push(source_card)
    end
    relevant_sources =
      if sources.empty?
        'None'
      else
        sources.map do |source|
          with_nest_mode :normal do
            subformat(source).render_relevant
          end
        end.join('')
      end
    content_tag(:div, relevant_sources.html_safe, class: 'relevant-sources')
  end

  view :cited_sources do |_args|
    render_haml do
      <<-HAML
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
    btn_class = 'btn btn-default _form_close_button'
    args[:buttons] =
      wrap_with :div do
        [
          submit_button(class: 'create-submit-button',
                        data: { disable_with: 'Adding...' }),
          content_tag(:button, 'Close', type: 'button', class: btn_class)
        ]
      end
    super(args)
  end

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
      #{_render_metric_details}
      <span class="metric-unit">
        #{legend(args)}
      </span>
      <div class="pull-right">
        <small>#{checked_value_flag.html_safe}</small>
        <small>#{comment_flag.html_safe}</small>
      </div>
    )
  end

  def grade
    return unless (value = (card.value && card.value.to_i))
    case value
    when 0, 1, 2, 3 then :low
    when 4, 5, 6, 7 then :middle
    when 8, 9, 10 then :high
    end
  end

  view :metric_details do
    span_args = { class: 'metric-value' }
    add_class span_args, grade if card.scored?
    wrap_with :span, span_args do
      fetch_value.html_safe
    end
  end

  def fetch_value
    if (value_type = card.metric_card.fetch trait: :value_type) &&
       %w(Number Money).include?(value_type.item_names[0]) &&
       !card.value_card.unknown_value?
      big_number = BigDecimal.new(card.value)
      number_to_human(big_number)
    else
      card.value
    end
  end

  def checked_value_flag
    checked_card = card.field 'checked_by'
    if checked_card && !checked_card.item_names.empty?
      css_class = 'fa fa-lg fa-check-circle verify-blue margin-left-10'
      content_tag('i', '', class: css_class, title: 'Value checked')
    else ''
    end
  end

  def comment_flag
    return '' unless Card.exists? card.cardname.field('discussion')
    disc = card.fetch(trait: :discussion)
    if disc.content.include? 'w-comment-author'
      css_class = 'fa fa-lg fa-commenting margin-left-10'
      content_tag('i', '', class: css_class, title: 'Has comments')
    else ''
    end
  end

  view :modal_details do |args|
    span_args = { class: 'metric-value' }
    add_class span_args, grade if card.scored?
    wrap_with :span, span_args do
      subformat(card)._render_modal_link(
        args.merge(
          text: fetch_value,
          path_opts: { slot: { show: :menu, optional_horizontal_menu: :hide } },
          html_args: {
            'data-complete-number' => card.value,
            'data-tooltip' => 'true',
            'data-placement' => 'top',
            'title' => card.value
          }
        )
      )
    end
  end

  view :value_link do
    url = "/#{card.cardname.url_key}"
    link = link_to card.value, url, target: '_blank'
    content_tag(:span, link.html_safe, class: 'metric-value')
  end

  # Metric value view for data
  view :timeline_data do
    wrap_with :div, class: 'timeline-row' do
      [
        _render_year,
        _render_value
      ]
    end
  end

  view :year do
    year = content_tag(:span, card.cardname.right)
    year << content_tag(:div, '', class: 'timeline-dot')
    content_tag(:div, year.html_safe, class: 'td year')
  end

  view :value do |args|
    value = content_tag(:span, currency, class: 'metric-unit')
    value << _render_value_link(args)
    value << content_tag(:span, legend(args), class: 'metric-unit')
    value << checked_value_flag.html_safe
    value << comment_flag.html_safe
    value << _render_value_details_toggle
    value << _render_value_details(args)
    content_tag(:div, value.html_safe, class: 'td value')
  end

  view :value_details do |args|
    checked_by = card.fetch trait: :checked_by, new: {}
    checked_by = nest(checked_by, view: :double_check_view)
    wrap_with :div, class: 'metric-value-details collapse' do
      [
        _optional_render(:credit_name, args, :show),
        content_tag(:div, checked_by.html_safe, class: 'double-check'),
        content_tag(:div, _render_sources, class: 'cited-sources'),
        content_tag(:div, _render_comments(args), class: 'comments-div')
      ]
    end
  end

  view :value_details_toggle do
    css_class = 'fa fa-caret-right fa-lg margin-left-10 btn btn-default btn-sm'
    content_tag(:i, '', class: css_class,
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

  view :comments do |_args|
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
