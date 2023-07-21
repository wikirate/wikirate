# Two main uses for this card:
# 1. exporting relationship answers on metric pages
# 2. returning subbrands on fashionchecker (should probably use a different pattern)

include_set Abstract::RelationshipSearch
include_set Abstract::MetricChild, generation: 1

def query_hash
  { metric_card.metric_lookup_field => metric_id }
end

format :html do
  def filter_map
    filter_map_without_keys super, :metric
  end
end
