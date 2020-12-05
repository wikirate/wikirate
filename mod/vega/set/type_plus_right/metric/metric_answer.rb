include_set Abstract::FixedMetricChart

format :json do
  def single_metric?
    true
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
