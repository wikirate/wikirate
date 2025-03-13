include_set Abstract::IdList

def topic
  left
end

event :update_topic_family_within_framework, :integrate, changed: :content do
  topic.topic_family_card.refresh_topic_family
end

def ok_item_types
  :topic_framework
end

format :html do
  def input_type
    :select
  end
end
