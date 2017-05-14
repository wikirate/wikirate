card_reader :projects_organized, type: :search_type
card_reader :metrics_designed, type: :search_type

format :html do
  def show_contributions_profile?
    main? && !Env.ajax? && !Env.params["about_company"] &&
      !contributions_about? && contributions_made?
  end

  def contributions_about?
    return false unless (count_card = card.fetch trait: :metric)
    count_card.cached_count.nonzero?
  end

  view :contribution_link do
    return "" unless contributions_made?
    link_to_card card.cardname.trait(:contribution), "View Contributions",
                 class: "btn btn-primary company-contribution-link"
  end

  def contributions_made?
    metrics_designed? || projects_organized?
    # FIXME: need way to figure this out without a search!
  end

  def metrics_designed?
    card.metrics_designed_card.count > 0
  end

  def projects_organized?
    card.projects_organized_card.count > 0
  end

  view :metric_contributions do
    field_subformat(:metrics_designed)._render_titled(
      show: :title_badge, items: { view: :metric_row }
    )
  end

  view :project_contributions do
    field_nest :projects_organized, view: :titled, show: :title_badge,
                                    items: { view: :listing }
  end
end
