# cache # of metrics tagged with this topic (=_left)
include Card::CachedCount

# recount metrics associated with a topic when <metric>+topic is edited
ensure_set { TypePlusRight::Metric::WikirateTopic }
recount_trigger TypePlusRight::Metric::WikirateTopic do |changed_card|
  names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |topic|
    Card.fetch topic.to_name.trait(:metric)
  end
end
