include_set Abstract::TopicSearch

def cql_content
  { type: :topic, left: left_id }
end

format :html do
  def default_limit
    50
  end

  def default_item_view
    :box
  end
end
