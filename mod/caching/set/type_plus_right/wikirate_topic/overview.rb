# cache # of articles for the topic (=_right)
include Card::CachedCount

ensure_set { TypePlusRight::WikirateAnalysis::WikirateArticle }
# update if article gets created or deleted
expired_cached_count_cards(
  set: TypePlusRight::WikirateAnalysis::WikirateArticle,
  on: [:create, :delete]
) do |changed_card|
  (analysis = changed_card.left) && (topic = analysis.right) &&
    topic.fetch(trait: :analyses_with_articles)
end
