include_set Abstract::IdList

assign_type :pointer

def history?
  false
end

def topic
  left
end

def refresh_topic_family
  family = topic.determine_topic_family

  if family.present?
    update content: family
  elsif real?
    delete
  end
end

# event :update_metric_topic_families, :integrate, changed: :content do
#   left.metric_card.item_cards.each do |metric|
#     metric.fetch(topic.topic_framework, new: {}).refresh_families
#   end
# end
