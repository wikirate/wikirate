include_set Abstract::ReadOnly

def infer
  topics = left.metric_card.item_cards.map do |metric|
    metric.topic_card.item_names
  end
  update content: topics.flatten.uniq
end
