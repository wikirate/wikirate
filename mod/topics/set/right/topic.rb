
# FIXME: should be on save, but this was breaking
# renames of +topic cards.  Should be fixed when references are
# represented with ids.
event :validate_topic_items, :validate, on: :create do
  return unless is_a? Abstract::List
  added_item_cards.each do |item_card|
    next if item_card.real? && item_card.type_id == TopicID
    errors.add :content, "invalid topic: #{item_card.name}"
  end
end

event :add_supertopics, :prepare_to_store do
  return unless is_a? Abstract::List
  added_item_cards.each do |item_topic|
    item_topic.supertopic_card.item_names.each do |supertopic|
      add_item supertopic
    end
  end
end

format :html do
  def default_limit
    50
  end

  def default_item_view
    :link
  end

  def input_type
    :multiselect
  end
end
