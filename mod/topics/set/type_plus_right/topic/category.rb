
event :inherit_category_topics, :prepare_to_store, on: :save do
  add_categories_to_topic_referers
end

def ok_item_types
  :topic
end

def option_names
  Card.search type: :topic, sort: :name, return: :name
end

format :html do
  def input_type
    :select
  end
end

private

def add_categories_to_topic_referers
  topic_referers.each do |pointer|
    pointer.add_item recursive_categories
  end
end

def topic_referers
  Card.search right: :topic, refer_to: left.id
end
