format :html do
  view :new do |args|
    return _render_no_frame_form args if Env.params[:noframe] == "true"
    @form_root = true
    frame do # no form!
      [
        _optional_render(:content_formgroup,
                         args.merge(metric_value_landing: true))
      ]
    end
  end

  def edit_slot args
    unless special_editor? args
      year = card.fetch trait: :year, new: {}
      year.content = "[[#{card.year}]]"
      args[:edit_fields] = {
        "+Value" => {},
        year => {}
      }
    end
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
    wrap_with :div do
      [
        _render_metric_value_landing_form(args),
        _render_source_container
      ]
    end
  end

  view :metric_value_landing_form do |args|
    html_class = "col-md-5 border-right panel-default min-page-height"
    hr = content_tag(:hr, "")
    wrap_with :div, class: html_class do
      [
        _render_hidden_source_field(args), hr,
        _render_company_field, hr,
        _render_metric_field(args),
        _render_next_button
      ]
    end
  end

  view :hidden_source_field do |args|
    if (source = args[:source])
      hidden_field "hidden_source", value: source
    end
  end

  view :company_field do
    field_nest(:wikirate_company, title: "Company")
  end

  view :metric_field do |args|
    metric = args[:metric]
    metric_field =
      Card.fetch(card.cardname.field(:metric), new: { content: metric })
    nest(metric_field, title: "Metric")
  end

  view :next_button do
    html_class = "col-md-6 col-centered text-center"
    button = content_tag(:a, "Next", class: "btn btn-primary _new_value_next")
    content_tag(:div, button, class: html_class)
  end

  view :source_container do |_args|
    render_haml do
      <<-HAML
.col-md-7.nopadding.panel-default
  .col-md-6.col-centered.text-center.light-grey-color-2
    %p
      Source Preview Container
    %p
      Please select a company and metric to add new sources and metric values.
      HAML
    end
  end

  view :no_frame_form do |args|
    form_opts[:hidden] = args.delete(:hidden)
    form_opts["main-success"] = "REDIRECT"
    card_form :create, form_opts do
      output [
        new_view_standard_hidden,
        new_view_name,
        new_view_type,
        _optional_render_content_formgroup,
        _optional_render_new_buttons
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
      right_plus: [["company", { refer_to: company }],
                   ["report_type", {
                     refer_to: {
                       referred_to_by: metric + "+report_type" } }]]
    )
  end

  view :relevant_sources do |args|
    sources = find_potential_sources args[:company], args[:metric]
    if (source_name = args[:source]) && (source_card = Card[source_name])
      sources.push(source_card)
    end
    relevant_sources =
      if sources.empty?
        "None"
      else
        sources.map do |source|
          with_nest_mode :normal do
            subformat(source).render_relevant
          end
        end.join("")
      end
    content_tag(:div, relevant_sources.html_safe, class: "relevant-sources")
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
    args[:hidden] = {
      success: { id: "_self", soft_redirect: true, view: :timeline_data }
    }
    if args[:metric]
      args[:hidden]["card[subcards][+metric][content]"] = args[:metric]
    end
    if args[:company]
      args[:hidden]["card[subcards][+company][content]"] = args[:company]
    end
    if args[:source]
      args[:hidden]["card[subcards][+source][content]"] = args[:source]
    end
  end

  def default_new_args args
    set_hidden_args args
    voo.title = "Add new value for #{args[:metric]}" if args[:metric]
    btn_class = "btn btn-default _form_close_button"
    args[:buttons] =
      wrap_with :div do
        [
          submit_button(class: "create-submit-button",
                        data: { disable_with: "Adding..." }),
          content_tag(:button, "Close", type: "button", class: btn_class)
        ]
      end
    super(args)
  end

  def legend args
    subformat(card.metric_card)._render_legend args
  end

  def currency
    return unless (value_type = Card["#{card.metric_card.name}+value type"])
    return unless value_type.item_names[0] == "Money" &&
                  (currency = Card["#{card.metric_card.name}+currency"])
    currency.content
  end
end
