# cache # of sources tagged with this topic (=_left)
include Card::CachedCount

ensure_set  { TypePlusRight::Source::WikirateTopic }

# needs update if topic list of a source has changed
expired_cached_count_cards set: TypePlusRight::Source::WikirateTopic do |changed_card|
  changed_card.item_names.map do |topic|
    Card.fetch "#{topic}+#{Card[:source].name}"
  end
end
