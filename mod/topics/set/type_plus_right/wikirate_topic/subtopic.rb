include_set Type::Pointer

event :validate_subtopics, :validate, on: :save do
  added_item_names.each do |subtopic|
    next if Card[subtopic]&.type_id == Card::WikirateTopicID

    errors.add :content, "invalid subtopic: #{subtopic}"
  end
end

event :update_supertopic_tags, :prepare_to_store, on: :save do
  added_item_names.each do |subtopic|
    add_topic_to_subtopic_referers subtopic
  end
end

def add_topic_to_subtopic_referers subtopic
  subtopic_referers(subtopic).each do |pointer|
    pointer.add_item name.left
    pointer.save
  end
end

def subtopic_referers subtopic, query={}
  query.merge! right: :wikirate_topic, type_id: Card::PointerID, refer_to: subtopic
  Card.search query
end

def ok_to_create
  super
  check_subtopic_permissions
end

def ok_to_update
  super
  check_subtopic_permissions
end

def check_subtopic_permissions
  return if as_moderator?

  deny_because "subtopic editing is currently restricted (beta testing)"
end
