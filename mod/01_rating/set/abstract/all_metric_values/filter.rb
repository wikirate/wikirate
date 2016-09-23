def key_type_id
  raise Error, "key_type_id not defined"
end

def filter_by_key _key
  raise Error, "filter_by_key not defined"
end

def filter cache
  return unless cache
  cache = all_without_values cache if Env.params["value"] == "none"
  cache.select { |key, values| pass_filter? key, values }
end

def pass_filter? key, values
  filter_by_key(key) &&
    filter_by_value(values) &&
    filter_by_year(values)
end


def filter_by_name metric
  return true unless Env.params["name"].present?
  metric.downcase.include?(Env.params["name"].downcase)
end

def filter_by_value values
  unit =
    if Env.params["value"].present?
      Env.params["value"]
    else
      "exists"
    end
  return values.empty? if unit == "none"
  return !values.empty? if unit == "exists"
  within_recent? unit, values
end

def filter_by_year values
  return true unless Env.params["year"].present?
  values.any? { |v| v["year"] == Env.params["year"] }
end

def filter_by_research_policy metric
  research_policy = Env.params["research_policy"]
  return true if !research_policy.present? || research_policy.size == 2
  rp_card = Card[metric].fetch trait: :research_policy, new: {}
  rp_card &&
    rp_card.item_names.any? { |s| s.casecmp(research_policy[0]).zero? }
end

def filter_by_type metric
  return true unless Env.params["type"].present?
  return false if Card[metric].type_id != MetricID
  mt = Card[metric].metric_type
  Env.params["type"].any? { |s| s.casecmp(mt).zero? }
end

def all_without_values existing_cache
  Card.search(type_id: key_type_id, return: :name)
      .reject { |name| existing_cache[name] }
      .each_with_object({}) do |name, res|
    res[name] = []
  end
end

def within_recent? unit, values
  time_diff = second_by_unit unit
  time_now = Time.now.to_i
  values.any? do |v|
    time_now - v["last_update_time"] <= time_diff
  end
end

def second_by_unit unit
  case unit
  when "last_hour"
    1.hour
  when "today"
    1.day
  when "week"
    1.week
  when "month"
    1.month
  end.to_i
end

def params_keys
  %w(name industry project)
end
