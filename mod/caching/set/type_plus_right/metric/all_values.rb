# cache all values in a json hash of the form
# company_id => [{ year => ..., value => ...}, ... ]

include_set Abstract::SolidCache, cached_format: :json

# recount # of values for a metric when ...

# ... a +value is changed
ensure_set { TypePlusRight::MetricValue::Value }
ensure_set { Type::MetricValue }

cache_update_trigger TypePlusRight::MetricValue::Value,
                     on: :update do |changed_card|
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


def value_caches_affected_by_metric_child_update changed_card
  needs_update = changed_card.metric_card &&
                 [changed_card.metric_card.all_values_card]
  needs_update ||= []
  if changed_card.name_changed?
    old_metric = changed_card.metric_card_before_name_change
    needs_update << old_metric.all_values_card if old_metric
  end
  needs_update
end


# get all metric values
def updated_content_for_cache changed_card=nil
  return super unless changed_card
  cached_hash = solid_cache
  # name changed?
  if changed_card.name_changed? && !changed_card.name_change.include?(nil)
    add_or_remove_value changed_card, cached_hash
  else
    cud_value_from_hash changed_card, cached_hash
  end
  cached_hash.to_json
end

private

def cud_value_from_hash changed_card, cached_hash
  if changed_card.trash?
    # value created or deleted or update
    # remove it from the cache
    remove_value_from_hash changed_card, cached_hash
  else
    # find if it exists in cache
    # exist -> update
    # not exist -> add one
    add_or_update_value changed_card, cached_hash
  end
end

def add_or_remove_value changed_card, cached_hash
  new_metric = extract_name(changed_card, :metric)
  if new_metric == metric
    # remove value from the same cache
    remove_value_from_hash changed_card, cached_hash
    add_value_to_hash changed_card, cached_hash
  else
    remove_value_from_hash changed_card, cached_hash
  end
end

def get_record_from_year records, year
  record = records.select { |row| row["year"] == year }
  record.empty? ? nil : record[0]
end

def get_value_card changed_card
  if changed_card.type_id == Card::MetricValueID
    changed_card.fetch trait: :value
  else
    changed_card
  end
end

def add_or_update_value changed_card, cached_hash
  company_id = get_key changed_card
  cached_hash[company_id] = [] unless cached_hash.key?(company_id)
  rows = cached_hash[company_id]
  row = get_record_from_year(rows, changed_card.year)
  value_card = get_value_card changed_card

  if rows.empty? || row.nil?
    rows.push construct_a_row(value_card)
  else
    row[:value] = value_card.value
  end
end

def add_value_to_hash changed_card, cached_hash
  company_id = get_key changed_card
  cached_hash[company_id] = [] unless cached_hash.key?(company_id)
  value_card = get_value_card changed_card
  cached_hash[company_id].push construct_a_row(value_card)
end

def remove_value_from_hash changed_card, cached_hash
  company_id = get_key changed_card, changed_card.trash? ? :new : :old
  values = cached_hash[company_id]
  return unless values
  values.delete_if { |row| row["year"] == changed_card.year }
  cached_hash.delete company_id if values.empty?
end
