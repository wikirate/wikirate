# cache # of articles for this company (=_left)
include Card::CachedCount

ensure_set { TypePlusRight::WikirateAnalysis::WikirateArticle }
# update if article gets created or deleted
expired_cached_count_cards(
  set: TypePlusRight::WikirateAnalysis::WikirateArticle,
  on: [:create, :delete]
) do |changed_card|
  (analysis = changed_card.left) && (company = analysis.left) &&
    company.fetch(trait: :analyses_with_articles)
end
