
def ok_item_types
  [:topic]
end

# when you add a topic to something, automatically also add the topic's categories
# NOTE: deleting does not delete
event :add_categories, :prepare_to_store, changed: :content do
  return unless is_a? Abstract::List
  added_item_cards.each do |item_topic|
    add_item item_topic.recursive_categories
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
