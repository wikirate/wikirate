# cache all values in a json hash of the form
# company_id => [{ year => ..., value => ...}, ... ]

include_set Abstract::SolidCache, cached_format: :json

# recount # of values for a metric when ...

# ... a +value is changed
ensure_set { TypePlusRight::MetricValue::Value }
ensure_set { Type::MetricValue }


def self.value_caches_affected_by_metric_child_update changed_card
  needs_update = changed_card.metric_card &&
    [changed_card.metric_card.all_values_card]
  needs_update ||= []
  if changed_card.name_changed?
    old_metric = changed_card.metric_card_before_name_change
    needs_update << old_metric.all_values_card if old_metric
  end
  needs_update
end

cache_update_trigger TypePlusRight::MetricValue::Value,
                     on: :save do |changed_card|
  value_caches_affected_by_metric_child_update changed_card
end

cache_update_trigger Type::MetricValue,
                     on: :delete do |changed_card|
  # don't trigger the update if the metric itself was deleted
  (mc = changed_card.metric_card) && !mc.trash && mc.all_values_card
end

cache_update_trigger TypePlusRight::MetricValue::Value,
                     on: :delete do |changed_card|
  # don't update if parent dealt with it
  next if @supercard && @supercard.type_id == MetricValueID &&
            @supercard.trash
  # don't trigger the update if the metric itself was deleted
  (mc = changed_card.metric_card) && !mc.trash && mc.all_values_card
end

# ... a Metric Value (type) is renamed
cache_update_trigger Type::MetricValue, on: :update do |changed_card|
  value_caches_affected_by_metric_child_update changed_card
end

# ... a Metric Value (type) is renamed
cache_update_trigger Type::MetricValue, on: :update do |changed_card|
  value_caches_affected_by_metric_child_update changed_card
end

# ... a Metric Value (type) is renamed
# cache_update_trigger TypePlusRight::MetricValue::Company, on: :update do |changed_card|
#   value_caches_affected_by_metric_child_update changed_card
# end


# get all metric values
def updated_content_for_cache changed_card=nil
  return super unless changed_card
  cv = MetricValuesHash.new metric, :company, solid_cache
  cv.update changed_card
  cv.to_json
end
