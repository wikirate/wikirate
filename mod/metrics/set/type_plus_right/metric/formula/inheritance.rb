include_set Abstract::Pointer

def inheritance_formula

end

format :html do
  def default_item_view
    :listing
  end

  def filter_card
    Card.fetch :metric, :browse_metric_filter
  end
end
