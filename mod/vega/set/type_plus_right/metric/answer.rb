include_set Abstract::Chart

format :json do
  def single_metric_chart?
    counts[:known] > 1
  end

  def metric_card
    @metric_card ||= card.left
  end
end

format :html do
  def show_chart?
    super && card.metric_card.chart_class
  end
end
