# Lookup table for metrics
class Metric < Cardio::Record
  @card_column = :metric_id

  include LookupTable

  fetcher designer_id: :metric_designer_id, title_id: :metric_title_id
  fetcher :scorer_id, :metric_type_id, :value_type_id, :unpublished

  has_many :answers, primary_key: :metric_id

  def card_query
    { type: Card::MetricID, trash: false }
  end

  # TODO: this should be implicit
  def fetch_metric_id
    card.id
  end

  def fetch_policy_id
    card.assessment_card&.first_id
  end

  def fetch_unit
    card.unit_card&.content
  end

  def fetch_hybrid
    card.hybrid_card&.checked?
  end

  def fetch_benchmark
    card.benchmark_card.checked?
  end
end
