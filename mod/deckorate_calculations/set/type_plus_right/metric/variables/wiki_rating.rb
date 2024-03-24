def weight_hash
  @weight_hash ||= hash_list.each_with_object({}) do |item, hash|
    hash[item[:metric].card_id] = item[:weight].to_f
  end
end

def map_wiki_rating_metric_and_context
  weight_hash.map { |metric, weight| yield metric, "#{weight}%" }
end

format :html do
  def wiki_rating_input
    custom_variable_input :wiki_rating_input
  end

  def wiki_rating_filtered_item_view
    :weight_row
  end

  def wiki_rating_filtered_item_wrap
    :none
  end
end
