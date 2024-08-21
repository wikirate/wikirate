def weight_hash
  @weight_hash ||= hash_list.each_with_object({}) do |item, hash|
    hash[item[:metric].card_id] = item[:weight].to_f
  end
end

def rating_metric_and_detail
  weight_hash.map { |metric, weight| [metric, "#{format.humanized_number weight}%"] }
end

format :html do
  def rating_algorithm
    "Answers are calculated as a weighted average. To find a weighted average of " \
    "a group of numbers that have been normalized to the same 0-10 scale, you simply " \
    "multiply each number by its weight (percentage) and add them up."
  end

  def rating_input
    custom_variable_input :rating_input
  end

  def rating_filtered_item_view
    :weight_row
  end

  def rating_filtered_item_wrap
    :none
  end
end
