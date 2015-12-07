# cache # of metrics tagged with this topic (=_left)
include Card::CachedCount

expired_cached_count_cards(
  set: TypePlusRight::Metric::WikirateTopic
) do |changed_card|
  changed_card.item_names.map do |topic|
    Card.fetch "#{topic}+#{Card[:metric].name}"
  end
end
