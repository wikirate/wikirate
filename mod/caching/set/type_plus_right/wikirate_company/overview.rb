# cache # of articles for this company (=_left)
include Card::CachedCount

# recount overviews associated with a company
# whenever article gets created or deleted
ensure_set { TypePlusRight::WikirateAnalysis::WikirateArticle }
recount_trigger(TypePlusRight::WikirateAnalysis::WikirateArticle,
                on: [:create, :delete]) do |changed_card|
  if (company_name = changed_card.cardname.left_name.left)
    Card.fetch company_name.to_name.trait(:analyses_with_articles)
  end
end
