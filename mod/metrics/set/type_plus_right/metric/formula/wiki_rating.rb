format :html do
  view :rating_core do
    table_content = table_content_with_items do |metric, weight|
      [nest(metric, view: :thumbnail_plain), "#{weight}%"]
    end
    table table_content, header: %w[Metric Weight]
  end

  def table_content_with_items
    card.translation_table.map do |metric, weight|
      yield metric, weight
    end
  end

  def editor_table_content
    table_content = editor_table_main_content
    table_content.push ["", sum_row(table_content)]
  end

  def editor_table_main_content
    table_content_with_items do |metric, weight|
      nest metric, view: :weight_row, weight: weight
    end
  end

  view :rating_editor, cache: :never do
    with_nest_mode :normal do
      output [table_editor(editor_table_content, %w[Metric Weight]),
              nest(card.variables_card, view: :edit_in_wikirating)]
    end
  end

  def sum_row table_content
    if table_content.empty?
      { content: sum_field, class: "hidden" }
    else
      sum_field
    end
  end

  def sum_field value=100
    text_field_tag "weight_sum", value, class: "weight-sum", disabled: true
  end
end
