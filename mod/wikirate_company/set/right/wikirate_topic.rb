event :create_missing_topics, :integrate, on: :save do
  topics = item_names
  topics.each do |topic|
    next if Card.exists? topic
    add_subcard topic, type_id: Card::WikirateTopicID
  end
end

format :html do
  def default_item_view
    :link
  end
end