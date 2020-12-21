include_set Abstract::FixedMetricChart

format :json do
  def single_metric_chart?
    counts[:known] > 1
  end

  def metric_card
    @metric_card ||= card.left
  end
end
