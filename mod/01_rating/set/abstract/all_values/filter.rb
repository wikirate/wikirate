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

def filter_by_value values
  value = Env.params["value"] || "exists"
  return values.empty? if value == "none"
  return !values.empty? if value == "exists"
  time_diff = second_by_unit value
  values.any? do |v|
    v["last_update_time"] <= time_diff
  end
end

def filter_by_year values
  return true unless Env.params["year"].present?
  values.any? { |v| v["year"] == Env.params["year"] }
end

def all_without_values existing_cache
  Card.search(type_id: key_type_id, return: :name)
      .reject { |name| existing_cache[name] }
      .each_with_object({}) do |name, res|
    res[name] = []
  end
end

def second_by_unit unit
  case unit
  when "last_hour"
    3600
  when "today"
    86_400
  when "week"
    604_800
  when "month"
    18_144_000
  end
end

def params_keys
  %w(name industry project)
end
