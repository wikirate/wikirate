# cache # of articles for this company (=_left)
include_set Abstract::CachedCount
include_set Abstract::WqlSearch

def virtual?
  true
end

def wql_hash
  { left_id: left.id,
    right: { type_id: WikirateTopicID },
    right_plus: ["Review", { refer_to: { type_id: ClaimID } }],
    sort: "name" }
end

# recount overviews associated with a company
# whenever article gets created or deleted
ensure_set { TypePlusRight::WikirateAnalysis::Overview }
recount_trigger(TypePlusRight::WikirateAnalysis::Overview,
                on: [:create, :delete]) do |changed_card|
  if (company_name = changed_card.cardname.left_name.left)
    Card.fetch company_name.to_name.trait(:analyses_with_articles)
  end
end
