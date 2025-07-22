include_set Abstract::IdList

assign_type :list

def ok_item_types
  [:topic]
end

# def item_cards_by_framework framework
#   # TODO: optimize
#   item_cards.select { |topic| topic.topic_framework_card.first_id == framework.card_id }
# end

def featured
  item_names & Card::Set::Self::Topic.family_names
end

# when you add a topic to something, automatically also add the topic's categories
# NOTE: deleting does not delete
event :add_categories, :prepare_to_store, changed: :content, on: :save do
  return unless is_a? Abstract::List

  added_item_cards.each do |item_topic|
    add_item item_topic.recursive_categories
  end
end

format :html do
  view :icon_badges, unknown: :blank, cache: :deep, template: :haml

  def default_limit
    50
  end

  def default_item_view
    :link
  end

  def input_type
    :topic_tree
  end

  def topic_tree_input
    haml :topic_tree_input
  end
end
