def weight_hash
  @weight_hash ||= hash_list.each_with_object({}) do |item, hash|
    hash[item[:metric].card_id] = item[:weight].to_f
  end
end

format :html do
  view :wiki_rating_core do
    wrap do
      [render_header(title: "Formula"),
       table(rating_core_table_content, header: %w[Metric Weight])]
    end
  end

  def wiki_rating_input
    with_nest_mode :normal do
      class_up "card-slot", filtered_list_slot_class
      wrap do
        [rating_editor_table,
         render_hidden_content_field,
         add_item_modal_link]
      end
    end
  end

  private

  def rating_core_table_content
    card.weight_hash.map do |metric, weight|
      [nest(metric, view: :thumbnail), "#{weight}%"]
    end
  end

  # table with Metrics on left and Weight inputs on right
  def rating_editor_table
    table rating_editor_table_content, class: "wikiRating-editor",
                                       header: ["Metric", haml(:weight_heading)]
  end

  def rating_editor_table_content
    table_content = rating_editor_table_main_content
    table_content.push ["Total", sum_cell(table_content)]
  end

  def rating_editor_table_main_content
    card.weight_hash.map do |metric, weight|
      subformat(metric).weight_row weight
    end.compact
  end

  # cell showing the total of all wikiratings
  def sum_cell table_content
    sum_content = text_field_tag "weight_sum", 100, class: "weight-sum", disabled: true
    sum_content = "#{sum_content}%"
    table_content.empty? ? { content: sum_content } : sum_content
  end
end
