# cache # of claims tagged with this topic (=_left)
include Card::CachedCount

# recount notes associated with a topic whenever <note>+topic is edited
ensure_set { TypePlusRight::Claim::WikirateTopic }
recount_trigger TypePlusRight::Claim::WikirateTopic do |changed_card|
  changed_card.item_names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:claim)
  end
end
