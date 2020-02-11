event :validate_topic_items, :validate, on: :save do
  return unless type_id == Card::PointerID
  added_item_cards.each do |item_card|
    next if item_card.real? && item_card.type_id == Card::WikirateTopicID
    errors.add :content, "invalid topic: #{item_card.name}"
  end
end

event :add_supertopics, :prepare_to_store do
  return unless type_id == Card::PointerID
  added_item_cards.each do |item_topic|
    item_topic.supertopic_card.item_names.each do |supertopic|
      add_item supertopic
    end
  end
end

format :html do
  def default_item_view
    :link
  end
end
