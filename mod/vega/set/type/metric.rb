def chart_class horizontal=false
  if numeric? || relation?
    numeric_chart_class horizontal
  elsif categorical?
    :bar_graph
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
