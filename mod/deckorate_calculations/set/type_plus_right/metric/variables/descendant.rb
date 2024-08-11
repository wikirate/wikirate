def descendant_metric_and_detail
  item_cards.map { |metric| [metric, nil] }
end

format :html do
  def descendant_algorithm
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
