# cache # of sources tagged with this topic (=_left)
include Card::CachedCount

ensure_set { TypePlusRight::Source::WikirateTopic }

# recount sources related to a topic whenever <source>+topic is edited
recount_trigger TypePlusRight::Source::WikirateTopic do |changed_card|
  changed_card.item_names.map do |topic|
    Card.fetch topic.to_name.trait(:source)
  end
end
