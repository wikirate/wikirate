event :create_missing_topics, after: :store, on: :save do
  topics = item_names
  topics.each do |topic|
    if !Card.exists? topic
      Card.create! type_id: Card::WikirateTopicID, name: topic
    end
  end
end
