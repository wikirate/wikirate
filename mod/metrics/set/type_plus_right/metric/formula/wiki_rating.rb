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
    table_content.push ["Total", sum_cell(table_content)]
  end

  def editor_table_main_content
    table_content_with_items do |metric, weight|
      subformat(metric).weight_row weight
    end
  end

  view :rating_editor, cache: :never do
    with_nest_mode :normal do
      output [table_editor(editor_table_content, %w[Metric Weight]),
              weight_row_template,
              nest(card.variables_card, view: :edit_in_wikirating)]
    end
  end

  def weight_row_template
    wrap_with :table, class: "weight-row-template hidden" do
      wrap_with :tr do
        card.left.format.weight_row 0, ""
      end
    end
  end

  def sum_cell table_content
    if table_content.empty?
      { content: sum_field }
    else
      sum_field
    end
  end

  def sum_field value=100
    field = text_field_tag "weight_sum", value, class: "weight-sum", disabled: true
    "#{field}%"
  end
end
