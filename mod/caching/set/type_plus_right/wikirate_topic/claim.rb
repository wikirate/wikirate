# cache # of claims tagged with this topic (=_left)
include Card::CachedCount

expired_cached_count_cards(
  set: TypePlusRight::Claim::WikirateTopic
) do |changed_card|
  # FIXME: we don't catch deletions of companies
  changed_card.item_cards.map do |topic|
    topic.fetch trait: :claim
  end
end
