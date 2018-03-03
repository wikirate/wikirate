
def inheritance_formula
  item_names.map do |item|
    "{{#{item}}}"
  end.join " || "
end

format :html do
  def default_item_view
    :listing
  end

  def filter_card
    Card.fetch :metric, :browse_metric_filter
  end

  view :ancestor_core do
    standard_pointer_core
  end
end
