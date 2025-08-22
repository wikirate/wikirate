include_set Abstract::IdList
include_set Abstract::StewardPermissions

assign_type :pointer

delegate :topic_families?, :determine_topic_family, to: :topic

def topic
  left
end

def stewarded_card
  topic.framework_card
end

event :assign_topic_family, :integrate,
      on: :save, changed: :content, when: :topic_families? do
  topic.topic_family_card.refresh_topic_family
end

event :inherit_category_topics, :prepare_to_store, changed: :content, on: :save do
  add_categories_to_topic_referers
end

def ok_item_types
  :topic
end

def option_names
  Card.search type: :topic, sort: :name, return: :name
end

def ok_to_create?
  super && check_category_permissions
end

def ok_to_update?
  super && check_category_permissions
end

format :html do
  def input_type
    :select
  end
end

private

def add_categories_to_topic_referers
  topic_referers.each do |pointer|
    pointer.add_item left.recursive_categories
    pointer.save
  end
end

def topic_referers
  Card.search right: :topic, refer_to: left.name
end

def check_category_permissions
  return true if as_moderator?

  deny_because "category editing is currently restricted (beta testing)"
end
