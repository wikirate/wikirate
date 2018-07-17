format :html do
  # default tab list (several metric types override)
  def tab_list
    %i[details project]
  end

  view :details_tab do
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
      field_nest :project, view: :titled, title: "Projects", items: { view: :listing }
    end
  end

  view :score_tab do
    tab_wrap do
      output [score_cards_table, add_score_link]
    end
  end

  def tab_options
    opts = super
    opts[:score] = { count: card.score_card.count } if tab_list.include?(:score)
    opts
  end

  def score_cards_table
    wikirate_table :plain, card.score_card.item_cards, [:score_thumbnail],
                   header: ["scored by"], tr_link: ->(item) { path mark: item }
  end

  def add_score_link
    link_to_card :metric, "Add new score",
                 path: { action: :new, tab: :score, metric: card.name },
                 class: "btn btn-primary"
  end
end
