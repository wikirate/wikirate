include_set Abstract::AllValues

def virtual?
  true
end

def raw_content
  %(
    {
      "left":{
        "type":"metric_value",
        "left":{
          "right":"_left"
        }
      },
      "right":"value",
      "limit":0
    }
  )
end

def sort_params
  [
    (Env.params["sort_by"] || "name"),
    (Env.params["sort_order"] || "asc")
  ]
end

def cached_values
  @cached_metric_values ||= get_cached_values

  if @cached_metric_values
    result = @cached_metric_values.select do |metric, values|
      filter metric, values
    end
    result
  else
    @cached_metric_values
  end
end

def filter metric, values
  filter_by_name(metric) &&
    filter_by_topic(metric) &&
    filter_by_research_policy(metric) &&
    filter_by_vote(metric) &&
    filter_by_type(metric) &&
    filter_by_value(values) &&
    filter_by_year(values)
end

def filter_by_name metric
  return true unless Env.params["metric"].present?
  metric.downcase.include?(Env.params["metric"].downcase)
end

def filter_by_topic metric
  return true unless Env.params["wikirate_topic"].present?
  topic_cards = Card[metric].fetch trait: :wikirate_topic
  topic_cards && topic_cards.item_names.include?(Env.params["wikirate_topic"])
end

def filter_by_research_policy metric
  return true unless Env.params["research_policy"].present?
  research_policy_card = Card[metric].fetch trait: :research_policy, new: {}
  research_policy_card &&
    research_policy_card.item_names.include?(Env.params["research_policy"])
end

def filter_by_vote metric
  return true unless Env.params["vote"].present? && Env.params["vote"] != "all"
  votee_type = Env.params["vote"]
  votee_search = "#{Auth.current.name}+metric+#{votee_type}_search"
  @votee_search ||= Card.fetch(votee_search).item_names
  @votee_search.include?(metric)
end

def filter_by_type metric
  return true unless Env.params["metric_type"].present?
  return false if Card[metric].type_id != MetricID
  mt = Card[metric].metric_type
  Env.params["metric_type"].any? { |s| s.casecmp(mt) == 0 }
end

def filter_by_value values
  value = Env.params["value"] || "exists"
  return values.empty? if value == "none"
  return !values.empty? if value == "exists"
  time_diff = get_second_by_unit value
  values.any? do |v|
    v["last_update_time"] <= time_diff
  end
end

def get_second_by_unit unit
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

def filter_by_year values
  return true unless Env.params["year"].present?
  values.any? { |v| v["year"] == Env.params["year"] }
end

format do
  def num?
    false
  end
end

format :html do
  view :card_list_items do |args|
    search_results.map do |row|
      c = Card["#{row[0]}+#{card.cardname.left}"]
      render :card_list_item, args.clone.merge(item_card: c)
    end.join "\n"
  end

  view :card_list_header do
    sort_by, sort_order = card.sort_params
    company_sort_order, value_sort_order = sort_order sort_by, sort_order
    company_sort_icon, value_sort_icon = sort_icon sort_by, sort_order
    %(
      <div class='yinyang-row column-header'>
        <div class='company-item value-item'>
          #{sort_link "Metrics #{company_sort_icon}",
                      sort_by: 'company_name', order: company_sort_order,
                      class: 'header'}
          #{sort_link "Values #{value_sort_icon}",
                      sort_by: 'value', order: value_sort_order,
                      class: 'data'}
        </div>
      </div>
    )
  end

  view :metric_list do |_args|
    wrap_with :div, class: "yinyang-list" do
      render_content(hide: "title",
                     items: { view: :metric_row })
    end
  end
end
