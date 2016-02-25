# cache # of metrics tagged with this topic (=_left)
include Card::CachedCount

# recount metrics associated with a topic when <metric>+topic is edited
ensure_set { TypePlusRight::Metric::WikirateTopic }
recount_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  changed_card.item_names.map do |topic|
    Card.fetch topic.to_name.trait(:metric)
  end
end
