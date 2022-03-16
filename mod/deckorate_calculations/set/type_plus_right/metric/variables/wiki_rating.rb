def weight_hash
  @weight_hash ||= hash_list.each_with_object({}) do |item, hash|
    hash[item[:metric].card_id] = item[:weight].to_f
  end
end

format :html do
  view :wiki_rating_core do
    table(rating_core_table_content, header: %w[Metric Weight])
  end

  def rating_core_table_content
    card.weight_hash.map do |metric, weight|
      [nest(metric, view: :thumbnail), "#{weight}%"]
    end
  end

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
