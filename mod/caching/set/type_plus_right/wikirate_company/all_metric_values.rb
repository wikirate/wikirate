include_set Abstract::UpdateAllMetricValuesCache
include_set Abstract::SolidCache, cached_format: :json

def self.value_cache_parent changed_card
  changed_card.company_card
end

def self.value_cache_parent_was changed_card
  changed_card.company_card_before_name_change
end

# recount # of values for a metric when ...

# ... a +value is changed
ensure_set { TypePlusRight::MetricValue::Value }
ensure_set { Type::MetricValue }

cache_update_trigger TypePlusRight::MetricValue::Value,
                     on: :save do |changed_card|
  values_caches_affected_by changed_card
end

# ... a Metric Value (type) is renamed
cache_update_trigger Type::MetricValue, on: :update do |changed_card|
  values_caches_affected_by changed_card
end

cache_update_trigger Type::MetricValue,
                     on: :delete do |changed_card|
  related_all_values_card changed_card
end

cache_update_trigger TypePlusRight::MetricValue::Value,
                     on: :delete do |changed_card|
  # don't update if parent dealt with it
  next if @supercard && @supercard.id == changed_card.left_id &&
    @supercard.trash
  related_all_values_card changed_card
end

