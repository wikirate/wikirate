format :html do
  # default tab list (several metric types override)
  def tab_list
    %i[details calculation project]
  end

  view :details_tab do
    add_name_context
    tab_wrap do
      [_render_metric_properties,
       wrap_with(:hr, ""),
       render_main_details]
    end
  end

  # overridden in Researched
  view :main_details do
    output [nest_formula, nest_about, nest_methodology].compact
  end

  def nest_about
    # return "" if card.about_card.new?
    nest card.about_card, view: :titled, title: "About"
  end

  def nest_formula
    nest card.formula_card, view: :titled, title: "Formula"
  end

  def nest_methodology
    return unless card.researchable?
    nest card.methodology_card, view: :titled, title: "Methodology"
  end

  view :project_tab do
    tab_wrap do
      field_nest :project, view: :titled, title: "Projects", items: { view: :mini_bar }
    end
  end

  view :calculation_tab do
    tab_wrap do
      output [calculations_list, add_score_link]
    end
  end

  def calculations_list
    card.directly_dependent_metrics.map do |metric|
      nest metric, view: :mini_bar
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
