format :html do
  view :rating_core do
    table_content = card.translation_table.map do |metric, weight|
      [nest(metric, view: :thumbnail_plain), "#{weight}%"]
    end
    table table_content, header: %w[Metric Weight]
  end

  view :rating_editor, cache: :never do
    with_nest_mode :normal do
      output [rating_editor_table,
              _render_hidden_content_field,
              weight_row_template,
              nest(card.variables_card, view: :edit_in_wikirating)]
    end
  end

  # table with Metrics on left and Weight inputs on right
  def rating_editor_table
    table rating_editor_table_content, class: "wikiRating-editor",
                                       header: ["Metric", weight_heading]
  end

  def weight_heading
    content_tag :div do
      concat(content_tag(:span, "Weight"))
      concat(checkbox)
    end
  end

  def checkbox
    content_tag :div, class: "form-check checkbox-pull pull-right" do
      content_tag :label, class: "form-check-label" do
        concat((check_box_tag "equalizer"))
        concat(content_tag(:span, "Equalize"))
      end
    end
  end

  def rating_editor_table_content
    table_content = rating_editor_table_main_content
    table_content.push ["Total", sum_cell(table_content)]
  end

  def rating_editor_table_main_content
    card.translation_table.map do |metric, weight|
      # FIXME: prevent bad data
      next unless Card.fetch_type_id(metric) == Card::MetricID
      subformat(metric).weight_row weight
    end.compact
  end

  # blank weight row used in JavaScript when new metric variables are added
  def weight_row_template
    wrap_with :table, class: "_weight-row-template hidden" do
      wrap_with :tr do
        card.left.format.weight_row 0, ""
      end
    end
  end

  # cell showing the total of all wikiratings
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
