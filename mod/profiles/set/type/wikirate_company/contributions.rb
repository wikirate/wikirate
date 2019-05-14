card_reader :projects_organized, type: :search_type
card_reader :metrics_designed, type: :search_type

format :html do
  view :contribution_link do
    return "" unless contributions_made?
    link_to_card card.name.trait(:contribution), "View Contributions",
                 class: "btn btn-primary company-contribution-link"
  end

  def contributions_made?
    metrics_designed? || projects_organized?
    # FIXME: need way to figure this out without a search!
  end

  def metrics_designed?
    card.metrics_designed_card.count.positive?
  end

  def projects_organized?
    card.projects_organized_card.count.positive?
  end

  view :metric_contributions do
    field_nest :metrics_designed, view: :titled, show: :title_badge
  end

  view :project_contributions do
    field_nest :projects_organized, view: :titled
  end
end
