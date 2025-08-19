include_set Abstract::IdList
include_set Abstract::StewardPermissions

assign_type :list

def topic_framework
  left
end

def stewarded_card
  topic_framework
end

event :apply_family_restriction, :finalize, changed: :content do
  topic_framework.topic_card.item_cards.each do |topic|
    topic.topic_family_card.refresh_topic_family
  end
end

format :html do
  def default_limit
    50
  end
end
