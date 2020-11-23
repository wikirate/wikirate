include_set Abstract::Chart

HORIZONTAL_MAX = 10

format :json do
  def vega
    VegaChart::SingleMetric.new self, chart_metric #, horizontal: horizontal?
  end

  def horizontal?
    count_by_status[:known] <= HORIZONTAL_MAX
  end

  def chart_metric
    card.left
  end

  def chart_query
    query
  end
end

format :html do
  def show_chart?
    super && count_by_status[:known].to_i.positive?
  end
end
