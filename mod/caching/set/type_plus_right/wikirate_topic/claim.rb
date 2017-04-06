# cache # of claims tagged with this topic (=_left)
include_set Abstract::CachedCount
include_set Abstract::WqlSearch

def virtual?
  true
end

def wql_hash
  { type_id: ClaimID, right_plus: [WikirateTopicID, {refer_to: left.id }] }
end

# recount notes associated with a topic whenever <note>+topic is edited
ensure_set { TypePlusRight::Claim::WikirateTopic }
recount_trigger TypePlusRight::Claim::WikirateTopic do |changed_card|
  names = Abstract::CachedCount.pointer_card_changed_card_names(changed_card)
  names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:claim)
  end
end
