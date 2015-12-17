# cache # of metrics with values for the company (=_ll) and taged
# with the topic (=_lr)
# the query for items that get counted
# (analysis+metrics+*type_plus_right+*structure):
# "type":"metric",
# "right_plus":[
#   ["topic",{"refer_to":"_2"}],
#   ["_ll",{"right_plus":["*cached count",{"ne":0}]}]
# ]
include Card::CachedCount

# update if topic taging is touched
ensure_set { TypePlusRight::Metric::WikirateTopic }
expired_cached_count_cards(
  set: TypePlusRight::Metric::WikirateTopic
) do |changed_card|
  changed_card.item_names.each do |topic|
    Card.fetch topic.to_name.trait(:metric)
  end
end

# update if the cached count card that caches the latest value
# is created. This means there is at least one value.
ensure_set { Right::CachedCount }
expired_cached_count_cards(
  set: Right::CachedCount, on: :create
) do |changed_card|
  next unless (l = changed_card.left) && (metric = l.left) &&
              (company = l.right) &&
              metric.type_code == :metric &&
              company.type_code == :wikirate_company
  # only <metric>+<company>+*cached count
  # we can't get this with a set

  # update if metric ist tagged with topics
  next unless (topic_card = metric.fetch trait: :wikirate_topic) &&
     (topic_cards = topic_card.item_names) && topic_cards.size > 0
  Card.search type_id: Card::WikirateAnalysisID, left: company.name,
              right: topic_cards.unshift('in'),
              append: 'metric'
end

