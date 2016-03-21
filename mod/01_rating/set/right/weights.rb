def metric_card
  left.left
end

def formula_card
  left
end

format :html do
  table_content = formula_card.translation_table.map do |metric, weight|
    metric_thumbnail = with_nest_mode :normal do
      subformat(metric)._render_thumbnail(args)
    end
    [{ content: metric_thumbnail, 'data-key': metric },
     text_field_tag('pair_value', weight, class: 'metric-weight')
    ]
  end
  table_content.push(
    ['', sum_field]
  )
  table_editor(table_content, ['Metric','Weight']) + with_nest_mode(:normal) do
    subformat(card.variables_card)._render_add_metric_button(args)
  end

  def sum_field value=100
    text_field_tag 'weight_sum', value, class: 'weight-sum', disabled: true
  end
end