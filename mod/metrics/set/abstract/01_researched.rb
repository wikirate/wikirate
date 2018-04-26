def score_cards
  # we don't check the metric type
  # we assume that a metric with left is a metric again is always a score
  Card.search type_id: MetricID,
              left_id: id
end

format :html do
  before :content_formgroup do
    super
    voo.edit_structure += [
      [:value_type, "Value Type"],
      [:research_policy, "Research Policy"],
      [:report_type, "Report Type"]
    ]
  end

  def tab_list
    %i[details score source project]
  end

  def tab_options
    { score: { count: card.score_cards.count } }
  end

  view :main_details do
    output [
      nest(card.about_card, view: :titled, title: "About"),
      nest(card.methodology_card, view: :titled, title: "Methodology"),
      _render_import_button
    ]
  end

  view :source_tab do
    tab_wrap do
      field_nest :source, view: :titled,
                          title: "#{fa_icon 'globe'} Sources",
                          items: { view: :listing }
    end
  end

  view :score_tab do
    # TODO: move +scores to a separate card
    tab_wrap do
      output [
        wikirate_table(:plain, card.score_cards, [:score_thumbnail],
                       header: ["scored by"], tr_link: ->(item) { path mark: item }),
        add_score_link
      ]
    end
  end

  def add_score_link
    link_to_card :metric, "Add new score",
                 path: { action: :new, tab: :score, metric: card.name },
                 class: "btn btn-primary"
  end

  def add_value_link
    link_to_card :research_page, "#{fa_icon 'plus'} Research answer",
                 path: { metric: card.name, view: :slot_machine },
                 class: "btn btn-primary",
                 title: "Research answer for another year"
    # "/new/metric_value?metric=" + _render_cgi_escape_name
  end

  view :add_value_buttons do
    return unless card.user_can_answer?
    wrap_with :div, class: "row margin-no-left-15" do
      [
        content_tag(:hr),
        add_value_link
      ]
    end
  end

  view :import_button do
    <<-HTML
      <h5>Bulk Import</h5>
        <div class="btn-group" role="group" aria-label="...">
          <a class="btn btn-outline-secondary btn-sm"
             href='/new/source?layout=wikirate%20layout'>
            <span class="fa fa-arrow-circle-o-down"></span>
            Import
          </a>
          <a class="btn btn-outline-secondary btn-sm slotter"
             href='/import_metric_values?layout=modal'
             data-toggle='modal' data-target='#modal-main-slot'>
            Help <small>(how to)</small>
          </a>
        </div>
    HTML
  end

  def properties
    super.merge research_properties
  end
end
