include_set Abstract::CachedCount
include_set Abstract::WqlSearch

def virtual?
  true
end

def wql_hash
  { type_id: ProjectID, right_plus:[WikirateTopicID, { refer_to: left.id }] }
end

# update count when <Project>+topic is changed
ensure_set { TypePlusRight::Project::WikirateTopic }
recount_trigger TypePlusRight::Project::WikirateTopic do |changed_card|
  topic_names = Abstract::CachedCount.pointer_card_changed_card_names(changed_card)
  topic_names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:project)
  end
end
