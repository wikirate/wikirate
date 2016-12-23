format :html do
  view :new do |args|
    return _render_table_form args if Env.params[:table_form]
    return _render_no_frame_form args if Env.params[:noframe] == "true"
    @form_root = true
    voo.editor = :metric_value_landing
    frame { _optional_render :content_formgroup }
  end

  view :content_formgroup do
    voo.hide :name_formgroup, :type_formgroup
    prepare_nests_editor unless custom_editor?
    super()
  end

  def prepare_nests_editor
    year = card.fetch trait: :year, new: { content: card.year }
    voo.editor = :nests
    voo.edit_structure = [[:value, {}], [year, {}]]
  end

  def custom_editor?
    metric_value_editor? || metric_value_landing_editor?
  end

  def metric_value_editor?
    Env.params[:company] && Env.params[:metric]
  end

  def metric_value_landing_editor?
    voo.editor == :metric_value_landing
  end

  view :editor, cache: :never do
    mv_view = if metric_value_editor?            then :editor
              elsif metric_value_landing_editor? then :landing
              end
    mv_view ? send("_render_metric_value_#{mv_view}") : super()
  end

  view :metric_value_landing do
    wrap_with :div do
      [
        _render_metric_value_landing_form,
        _render_source_container
      ]
    end
  end

  view :metric_value_landing_form do
    html_class = "col-md-5 border-right panel-default min-page-height"
    wrap_with :div, class: html_class do
      [
        _render_hidden_source_field, hr,
        _render_company_field, hr,
        _render_metric_field,
        _render_next_button
      ]
    end
  end

  def hr
    "<hr />"
  end

  view :hidden_source_field, cache: :never do
    if (source = Env.params[:source])
      hidden_field "hidden_source", value: source
    end
  end

  view :company_field do
    field_nest(:wikirate_company, title: "Company")
  end

  view :metric_field, cache: :never do
    metric_field = Card.fetch card.cardname.field(:metric),
                              new: { content: Env.params[:metric] }
    nest metric_field, title: "Metric"
  end

  view :next_button do
    wrap_with :div, class: "col-md-6 col-centered text-center" do
      wrap_with :a, "Next", href: "#", class: "btn btn-primary _new_value_next"
    end
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

  view :no_frame_form, cache: :never do
    card_form :create, "main-success" => "REDIRECT" do
      output [
        new_view_hidden,
        new_view_type,
        _optional_render_content_formgroup,
        _optional_render_new_buttons
      ]
    end
  end


  # TODO: please verify if this view used anywhere
  view :add_value_editor, cache: :never do |_args|
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

  view :metric_value_editor, cache: :never do |args|
    render_haml relevant_sources: _render_relevant_sources(args),
                cited_sources: _render_cited_sources,
                no_title: args[:no_title] do
      <<-HAML
.td.year
  = field_nest :year, title: (no_title ? " " : 'Year')
.td.value
  %span.metric-value
    = field_nest :value, title: (no_title ? " " : 'Value')
  %h5
    Choose Sources or
    %a.btn.btn-sm.btn-default._add_new_source{href: "#"}
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

  view :relevant_sources, cache: :never do |args|
    sources = find_potential_sources Env.params[:company], Env.params[:metric]
    if (source_name = Env.params[:source]) && (source_card = Card[source_name])
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
    wrap_with(:div, relevant_sources.html_safe, class: "relevant-sources")
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

  def new_view_hidden
    tags =
      { success: { id: "_self", soft_redirect: true, view: :thin_record_list } }
    [:metric, :company, :source].each do |field|
      next unless (value = Env.params[field])
      tags["card[subcards][+#{field}][content]"] = value
    end
    hidden_tags tags
  end

  view :new_buttons do
    button_formgroup do
      wrap_with :div do
        [
          submit_button(class: "create-submit-button",
                        data: { disable_with: "Adding..." }),
          wrap_with(:button, "Close",
                    type: "button",
                    class: "btn btn-default _form_close_button")
        ]
      end
    end
  end

  def default_new_args _args
    metric_name = Env.params[:metric]
    voo.title = "Add new value for #{metric_name}" if metric_name
  end

  def legend
    return if currency.present?
    subformat(card.metric_card)._render_legend
  end

  def currency
    return unless (value_type = Card["#{card.metric_card.name}+value type"])
    return unless value_type.item_names[0] == "Money" &&
                  (currency = Card["#{card.metric_card.name}+currency"])
    currency.content
  end
end
