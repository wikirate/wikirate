def map_descendant_metric_and_context
  item_cards.map { |metric| yield metric, nil }
end

format :html do
  def descendant_preface
    "Inherit from ancestor (in order of precedence)"
  end

  def descendant_input
    filtered_list_input
  end

  def descendant_filtered_item_view
    implicit_item_view
  end

  def descendant_filtered_item_wrap
    :filtered_list_item
  end
end
