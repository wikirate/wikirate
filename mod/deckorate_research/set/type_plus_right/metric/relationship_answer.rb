# Two main uses for this card:
# 1. exporting relationships on metric pages
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

format do
  # HACK! Following two methods are a workaround to keep company groups working
  # (needed for fashionchecker)
  # Long-term solution is to implement company group filtering in
  # Abstract::RelationshipSearch
  def filter_hash_from_params
    super.tap do |h|
      normalize_filter_hash h if h
    end
  end

  def normalize_filter_hash h
    group = h.delete :company_group
    company_ids = [group, :company].card&.item_ids
    h[company_field] = company_ids if company_ids.present?
  end

  private

  def company_field
    metric_card.inverse? ? :object_company_id : :subject_company_id
  end
end
