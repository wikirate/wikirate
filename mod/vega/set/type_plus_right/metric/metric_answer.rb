include_set Abstract::Chart

format :json do
  def vega
    VegaChart::SingleMetric.new self, chart_metric,
                                horizontal: false # chart_item_count < 10
  end

  def chart_metric
    card.left
  end
end

format :html do
  def show_chart?
    super && count_by_status[:known].to_i.positive?
  end
end
