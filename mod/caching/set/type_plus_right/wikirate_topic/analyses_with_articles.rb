# cache # of articles related this topic (=right) via the right part of the
# the analysis name
include_set Abstract::SearchCachedCount

def wql_hash
  { right_id: left.id,
    left: { type_id: WikirateCompanyID },
    right_plus: ["Review", { refer_to: { type_id: ClaimID } }],
    sort: "name" }
end

# recount overviews associated with a topic
# whenever article gets created or deleted
recount_trigger :type_plus_right, :wikirate_analysis, :overview,
                on: [:create, :delete] do |changed_card|
  if (topic_name = changed_card.name.left_name.right)
    Card.fetch topic_name.to_name.trait(:analyses_with_articles)
  end
end
