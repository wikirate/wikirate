# cache all values in a json hash of the form
# company_id => [{ year => ..., value => ...}, ... ]

include_set Abstract::SolidCache, cached_format: :json

# recount # of values for a metric when ...

# ... a +value is changed
ensure_set { TypePlusRight::MetricValue::Value }
ensure_set { Type::MetricValue }

def self.all_values_caches_affected_by changed_card
  needs_update = [related_all_values_card(changed_card)]
  if changed_card.name_changed?
    needs_update << related_all_values_card_was(changed_card)
  end
  needs_update.compact
end

def self.related_all_values_card changed_card
  # Don't trigger the update if the metric itself was deleted.
  # Not sure what happens during a delete request but probably
  # the fetch already returns nil
  (mc = changed_card.metric_card) && !mc.trash && mc.all_values_card
end

def self.related_all_values_card_was changed_card
  (mc = changed_card.metric_card_before_name_change) && mc.all_values_card
end

cache_update_trigger TypePlusRight::MetricValue::Value,
                     on: :save do |changed_card|
  all_values_caches_affected_by changed_card
end

# ... a Metric Value (type) is renamed
cache_update_trigger Type::MetricValue, on: :update do |changed_card|
  all_values_caches_affected_by changed_card
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

# ... a Metric Value (type) is renamed
# cache_update_trigger TypePlusRight::MetricValue::Company,
#                      on: :update do |changed_card|
#   value_caches_affected_by_metric_child_update changed_card
# end

# get all metric values
def updated_content_for_cache changed_card=nil
  return super unless changed_card
  cv = MetricValuesHash.new left, solid_cache
  cv.update changed_card
  cv.to_json
end
