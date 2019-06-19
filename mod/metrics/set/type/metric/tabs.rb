include_set Abstract::Filterable

format :html do
  # default tab list (several metric types override)
  def tab_list
    %i[details calculation project]
  end

  view :tabs do
    super()
  end

  view :details_tab do
    tab_wrap do
      [render_metric_properties, render_main_details]
    end
  end

  # overridden in Researched
  view :main_details do
    [nest_formula, nest_about, nest_methodology]
  end

  def nest_about
    field_nest :about, view: :titled
  end

  def nest_formula
    field_nest :formula, view: :titled
  end

  def nest_methodology
    return unless card.researchable?
    field_nest :methodology, view: :titled
  end

  def answer_filtering
    filtering(".RIGHT-answer ._filter-widget") do
      yield view: :bar, show: :full_page_link, hide: %i[metric_header edit_link]
    end
  end

  view :project_tab do
    answer_filtering do |items|
      tab_wrap do
        field_nest :project, view: :content, items: items
      end
    end
  end

  view :calculation_tab do
    tab_wrap do
      output [calculations_list, add_score_link]
    end
  end

  def calculations_list
    card.directly_dependent_metrics.map do |metric|
      nest metric, view: :bar
    end.join
  end

  def tab_options
    { calculation: { count: card.directly_dependent_metrics.size } }
  end

  def add_score_link
    return if card.score?
    link_to_card :metric, "Add new score",
                 path: { action: :new, tab: :score, metric: card.name },
                 class: "btn btn-primary mt-4"
  end
end
