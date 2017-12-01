def key_type_id
  raise Error, "key_type_id not defined"
end

def filter_by_key key
  filter_by_name key
end

def filter_by_values _key, _values
  true
end

def filter cache
  return unless cache
  cache = all_without_values cache if Env.params["value"] == "none"
  cache.select do |key, values|
    pass_filter?(key, values) &&
      (!values.is_a?(Array) ||
        (values.select! { |v| pass_single_value_filter?(key, v) }.nil? ||
         values.present?))
  end
end

def pass_filter? key, values
  filter_by_key(key) && filter_by_values(key, values)
end

def pass_single_value_filter? _key, _value
  true
end

def filter_by_name key
  keep_if :name do |filter|
    key.downcase.include?(filter.downcase)
  end
end

def filter_by_value values
  keep_if :metric_value, default: "exists" do |filter|
    case filter
    when "none" then values.empty?
    when "exists" then !values.empty?
    when "outliers" then true
    else within_recent? filter, values
    end
  end
end

def filter_by_year _key, _value # values
  values = Array.wrap(values)
  keep_if :year do |filter|
    values.any? { |v| v["year"] == filter }
  end
end

def filter_by_research_policy metric
  keep_if :research_policy, options: 2 do |filter|
    rp_card = Card[metric].fetch trait: :research_policy, new: {}
    rp_card&.item_names&.any? { |s| s.casecmp(filter[0]).zero? }
  end
end

def filter_by_topic metric
  keep_if :wikirate_topic do |filter|
    topic_cards = Card[metric].fetch trait: :wikirate_topic
    topic_cards&.item_names&.include?(filter)
  end
end

def filter_by_metric_type metric
  keep_if :type do |filter|
    return false if Card[metric].type_id != MetricID
    mt = Card[metric].metric_type
    filter.any? { |s| s.casecmp(mt).zero? }
  end
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
  %w[name industry project]
end

def keep_if field, args={}
  filter =
    Env.params[field.to_s].present? ? Env.params[field.to_s] : args[:default]
  return true unless filter
  return true if args[:options] && field.is_a?(Array) &&
                 field.size == args[:options]  # all options selected
  yield filter
end
