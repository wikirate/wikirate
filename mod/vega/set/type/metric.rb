def chart_class horizontal=false
  if numeric? || relationship?
    numeric_chart_class horizontal
  elsif categorical?
    :category_chart
  else
    raise Card::Error, "VegaChart not supported for #{name}"
  end
end

def numeric_chart_class horizontal
  if horizontal
    :horizontal_bar
  elsif ten_scale?
    :ten_scale_histogram
  else
    :histogram
  end
end