include_set Abstract::RelationshipSearch
include_set Abstract::MetricChild, generation: 3

def query_hash
  { metric_card.answer_lookup_field => left.id }
end

format :html do
  delegate :metric, :company, :year, to: :card

  def filter_map
    filter_map_without_keys super, :metric, :year
  end
end
