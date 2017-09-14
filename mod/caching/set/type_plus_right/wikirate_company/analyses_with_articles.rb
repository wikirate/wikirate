# cache # of articles related this company (=left) via the left part of the
# the analysis name
include_set Abstract::SearchCachedCount

def wql_hash
  { left_id: left.id,
    right: { type_id: WikirateTopicID },
    right_plus: ["Review", { refer_to: { type_id: ClaimID } }],
    sort: "name" }
end

# recount overviews associated with a company
# whenever article gets created or deleted
recount_trigger :type_plus_right, :wikirate_analysis, :overview,
                on: [:create, :delete] do |changed_card|
  if (company_name = changed_card.cardname.left_name.left)
    Card.fetch company_name.to_name.trait(:analyses_with_articles)
  end
end
