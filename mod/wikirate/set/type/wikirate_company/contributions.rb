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
    Card.search(type_id: MetricID, left: card.name, return: "count") > 0
  end

  def projects_organized?
    Card.search(type_id: ProjectID,
                right_plus: ["organizer", { refer_to: card.name }],
                return: "count") > 0
  end
end

def indirect_contributor_search_args
  [
    { type_id: Card::ClaimID,  right_plus: ["company", { link_to: name }] },
    { type_id: Card::SourceID, right_plus: ["company", { link_to: name }] },
    { type_id: Card::WikirateAnalysisID, left: name },
    { type_id: Card::MetricValueID, left: { right: name } }
  ]
end