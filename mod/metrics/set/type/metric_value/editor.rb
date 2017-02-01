format :html do
  view :new, cache: :never do
    return _render_no_frame_form if Env.params[:noframe] == "true"
    @form_root = true
    subformat(Card[:research_page])._render_new
  end

  view :content_formgroup, cache: :never do
    voo.hide :name_formgroup, :type_formgroup
    prepare_nests_editor unless custom_editor?
    super()
  end

  def prepare_nests_editor
    voo.editor = :nests
    card.add_subfield :year, content: card.year
    voo.edit_structure = [[:value, "Value"], [:year, "Year"]]
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

  def special_editor
    @special_editor ||=
      if metric_value_editor?            then :editor
      elsif metric_value_landing_editor? then :landing
      end
  end

  view :editor, cache: :never do
    with_nest_mode :edit do
      special_editor ? send("_render_metric_value_#{special_editor}") : super()
    end
  end

  def hr
    "<hr />"
  end

  def hidden_source_field
    if (source = Env.params[:source])
      hikdden_field "hidden_source", value: source
    end
  end

  def company_field
    field_nest(:wikirate_company, title: "Company")
  end

  def metric_field
    metric_field = Card.fetch card.cardname.field(:metric),
                              new: { content: Env.params[:metric] }
    nest metric_field, title: "Metrics"
  end

  def next_button
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
    %a.btn.btn-sm.btn-default._add_new_source{href: "#", data: {url: "test"}}
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
    sources =
      find_potential_sources(Env.params[:company] || card.company,
                             Env.params[:metric] || card.metric)
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
      { success: { id: "_self", soft_redirect: true, view: :record_list } }
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
