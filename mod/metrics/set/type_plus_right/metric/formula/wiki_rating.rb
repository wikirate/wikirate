format :html do
  view :rating_core do |args|
    table_content =
      card.translation_table.map do |metric, weight|
        [subformat(metric)._render_thumbnail_plain(args), "#{weight}%"]
      end
    table table_content, header: %w[Metric Weight]
  end

  def editor_table_content args
    card.translation_table.map do |metric, weight|
      with_nest_mode :normal do
        subformat(metric)._render_weight_row(args.merge(weight: weight))
      end
    end
  end

  view :rating_editor, cache: :never do |args|
    table_content = editor_table_content(args)
    sum =
      if table_content.empty?
        { content: sum_field, class: "hidden" }
      else
        sum_field
      end
    table_content.push ["", sum]
    output [
      table_editor(table_content, %w[Metric Weight]),
      nest(card.variables_card, view: :add_metric_button)
    ]
  end

  def sum_field value=100
    text_field_tag "weight_sum", value, class: "weight-sum", disabled: true
  end
end
