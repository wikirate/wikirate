RSpec.describe Card::Set::TypePlusRight::Metric::MetricType do
  def card_subject
    sample_metric.metric_type_card
  end

  check_views_for_errors
end
