assign_type :pointer

def history?
  false
end

def topic
  left
end

def refresh_topic_family
  family = topic.determine_topic_family

  if family.nil?
    delete if real?
  else
    update content: family
  end
end

# event :update_metric_topic_families, :integrate, changed: :content do
#   left.metric_card.item_cards.each do |metric|
#     metric.field(topic.topic_framework&.cardname, content:
#   end
# end
