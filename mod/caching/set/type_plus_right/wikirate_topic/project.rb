include Card::CachedCount

# update count when <Project>+topic is changed
ensure_set { TypePlusRight::Project::WikirateTopic }
recount_trigger TypePlusRight::Project::WikirateTopic do |changed_card|
  topic_names = Card::CachedCount.pointer_card_changed_card_names(changed_card)
  topic_names.map do |topic_name|
    Card.fetch topic_name.to_name.trait(:project)
  end
end
