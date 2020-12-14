include_set Abstract::FixedMetricChart

format :json do
  def single_metric?
    true
  end

  def metric_card
    @metric_card ||= card.left
  end
end
