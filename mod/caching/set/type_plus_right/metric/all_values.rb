# cache all values in a json hash of the form
# company => [{ year => ..., value => ...}, ... ]

include Card::CachedCount

# recount # of values for a metric when ...

# ... a +value is changed
ensure_set { TypePlusRight::MetricValue::Value }
ensure_set { Type::MetricValue }

recount_trigger TypePlusRight::MetricValue::Value do |changed_card|
  metric_cache = [changed_card.metric_card.fetch(trait: :all_values)]
  # changed names with nil mean create or delete
  if changed_card.name_changed? && !changed_card.name_change.include?(nil)
    old_metric_name = changed_card.name_change[0].to_name.parts[0..-4].join "+"
    if !old_metric_name.empty? && old_metric_name != changed_card.metric
      metric_cache.push Card.fetch(old_metric_name).fetch(trait: :all_values)
    end
  end
  metric_cache
end

# company rename and delete changes should also trigger the update?

# ... a Metric Value (type) is renamed, and deleted
recount_trigger Type::MetricValue do |changed_card|
  metric_cache = [changed_card.metric_card.fetch(trait: :all_values)]
  # it should also update the cache for the old name
  if changed_card.name_changed?
    old_metric_name = changed_card.name_change[0].to_name.parts[0..-3].join "+"
    if !old_metric_name.empty? && old_metric_name != changed_card.metric
      metric_cache.push Card.fetch(old_metric_name).fetch(trait: :all_values)
    end
  end
  metric_cache
end

# get all metric values
def calculate_count changed_card=nil
  if changed_card && fetch(trait: :cached_count)
    cached_hash = construct_cached_hash
    # name changed?
    if changed_card.name_changed? && !changed_card.name_change.include?(nil)
      add_or_remove_value changed_card, cached_hash
    else
      cud_value_from_hash changed_card, cached_hash
    end
    cached_hash.to_json
  else
    refresh_cache_completely
  end
end

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

def extract_name card, type, from=:new
  offset = card.type_id == Card::MetricValueID ? 0 : 1
  cardname = card_name(card, from).parts
  case type
  when :metric
    cardname[0..-3 - offset].join("+")
  when :year
    cardname[-1 - offset]
  when :company
    cardname[-2 - offset]
  end
end

def card_name card, from
  from == :new ? card.cardname : card.name_change[0].to_name
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
  company_id = company_id changed_card
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

def construct_a_row value_card
  { year: value_card.year, value: value_card.value }
end

def get_key changed_card, from=:new
  Card[extract_name(changed_card, :company, from)].id.to_s
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
  values.delete_if { |row| row["year"] == changed_card.year }
  cached_hash.delete company_id if values.empty?
end

def refresh_cache_completely
  result = {}
  item_cards(default_query: true).each do |value_card|
    company = value_card.company_card.id
    result[company] = [] unless result.key?(company)
    result[company].push construct_a_row(value_card)
  end
  result.to_json
end
