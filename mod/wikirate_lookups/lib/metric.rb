# Lookup table for metrics
class Metric < ApplicationRecord
  @card_column = :metric_id
  @card_query = { type_id: Card::MetricID, trash: false }

  include LookupTable

  fetcher designer_id: :metric_designer_id, title_id: :metric_title_id
  fetcher :scorer_id, :metric_type_id, :value_type_id

  # TODO: this should be implicit
  def fetch_metric_id
    card.id
  end

  def fetch_policy_id
    card.research_policy_card&.first_id
  end

  def fetch_unit
    card.unit_card&.content
  end

  def fetch_hybrid
    card.hybrid_card&.checked?
  end
end
