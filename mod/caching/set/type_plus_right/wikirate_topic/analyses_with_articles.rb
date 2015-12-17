# cache # of articles for the topic (=_right)
include Card::CachedCount

# recount overviews associated with a topic
# whenever article gets created or deleted
ensure_set { TypePlusRight::WikirateAnalysis::WikirateArticle }
recount_trigger(TypePlusRight::WikirateAnalysis::WikirateArticle,
                on: [:create, :delete]) do |changed_card|
  if (topic_name = changed_card.cardname.left_name.right)
    Card.fetch topic_name.to_name.trait(:analyses_with_articles)
  end
end
