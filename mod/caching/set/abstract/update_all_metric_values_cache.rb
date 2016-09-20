# cache all values in a json hash of the form
# company_id => [{ year => ..., value => ...}, ... ]


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
  (vcp = metric_valuchanged_card.metric_card) && !mc.trash && mc.all_metric_values_card
end

def self.related_all_values_card_was changed_card
  (mc = changed_card.metric_card_before_name_change) && mc.all_metric_values_card
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

