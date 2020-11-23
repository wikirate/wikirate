include_set Abstract::FixedMetricChart

HORIZONTAL_MAX = 10

format :json do
  def vega
    chart_class = metric_card.chart_class horizontal?
    VegaChart.new chart_class, self
  end

  def horizontal?
    count_by_status[:known] <= HORIZONTAL_MAX
  end

  def metric_card
    @metric_card ||= card.left
  end
end

format :html do
  def show_chart?
    super && count_by_status[:known].to_i.positive?
  end
end
