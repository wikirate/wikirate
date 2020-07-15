format :json do
  def atom
    super.merge(
      bookmarkers: card.bookmarkers_card.cached_count,
      metrics: card.metric_card.cached_count,
      projects: card.project_card.cached_count
    )
  end
end
