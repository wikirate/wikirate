include_set Abstract::AllValues

def raw_content
  %(
    {
      "left":{
        "type":"metric_value",
        "left":{ "right":"_left" }
      },
      "right":"value",
      "limit":0
    }
  )
end

def sort_params
  [(Env.params["sort"] || "upvoted"), "desc"]
end

def fill_metrics existing_cache
  result = {}
  Card.search(type_id: MetricID, return: :name).each do |metric|
    result[metric] = [] unless existing_cache[metric]
  end
  result
end

def cached_values
  @cached_metric_values ||= get_cached_values

  if @cached_metric_values
    # replace the cache with non existing metric if value is none
    if Env.params["value"] == "none"
      @cached_metric_values = fill_metrics @cached_metric_values
    end
    result = @cached_metric_values.select do |metric, values|
      filter metric, values
    end
    result
  else
    @cached_metric_values
  end
end

def filter metric, values
  filter_by_metric(metric) &&
    filter_by_value(values) &&
    filter_by_year(values)
end

def filter_by_metric metric
  filter_by_name(metric) &&
    filter_by_topic(metric) &&
    filter_by_research_policy(metric) &&
    filter_by_vote(metric) &&
    filter_by_type(metric)
end

def filter_by_name metric
  return true unless Env.params["name"].present?
  metric.downcase.include?(Env.params["name"].downcase)
end

def filter_by_topic metric
  return true unless Env.params["wikirate_topic"].present?
  topic_cards = Card[metric].fetch trait: :wikirate_topic
  topic_cards && topic_cards.item_names.include?(Env.params["wikirate_topic"])
end

def filter_by_research_policy metric
  research_policy = Env.params["research_policy"]
  return true if !research_policy.present? || research_policy.size == 2
  rp_card = Card[metric].fetch trait: :research_policy, new: {}
  rp_card &&
    rp_card.item_names.any? { |s| s.casecmp(research_policy[0]) == 0 }
end

def user_voted_metric votee_type
  votee_search = "#{Auth.current.name}+metric+#{votee_type}_search"
  Card.fetch(votee_search).item_names
end

def filter_by_vote metric
  vote_param = Env.params["my_vote"]
  return true if !vote_param.present? || vote_param.size == 3
  upvoted = upvoted_metric?(metric)
  downvoted = downvoted_metric?(metric)
  puts "@@ #{metric},#{upvoted},#{downvoted}".red
  fit_vote? upvoted, downvoted, vote_param
end

def fit_vote? upvoted, downvoted, vote_param
  not_voted = !upvoted && !downvoted
  result = false
  result |= upvoted if vote_param.include?("upvoted")
  result |= downvoted if vote_param.include?("downvoted")
  result |= not_voted if vote_param.include?("not voted")
  result
end

def upvoted_metric? metric
  @upvoted_metric ||= user_voted_metric("upvotee")
  @upvoted_metric.include?(metric)
end

def downvoted_metric? metric
  @downvoted_metric ||= user_voted_metric("downvotee")
  @downvoted_metric.include?(metric)
end

def filter_by_type metric
  return true unless Env.params["type"].present?
  return false if Card[metric].type_id != MetricID
  mt = Card[metric].metric_type
  Env.params["type"].any? { |s| s.casecmp(mt) == 0 }
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

def filter_by_year values
  return true unless Env.params["year"].present?
  values.any? { |v| v["year"] == Env.params["year"] }
end

format do
  def vote_status metric
    @upvoted_metric ||= card.user_voted_metric "upvotee"
    @downvoted_metric ||= card.user_voted_metric "downvotee"
    return :upvoted if @upvoted_metric.include?(metric)
    return :downvoted if @downvoted_metric.include?(metric)
    :none
  end

  def compare_metric metric1, metric2, value1, value2
    metric1_status = vote_status metric1
    metric2_status = vote_status metric2
    if metric1_status == metric2_status
      value1 <=> value2
    elsif metric1_status == :upvoted || metric2_status == :downvoted
      1
    elsif metric2_status == :upvoted || metric1_status == :downvoted
      -1
    end
  end

  def num?
    false
  end

  def latest_row_value row, key
    row[1].sort_by { |value| value[key] }.reverse[0][key]
  end

  def sort_recent_desc metric_values
    metric_values.sort do |x, y|
      value_a = latest_row_value x, "last_update_time"
      value_b = latest_row_value y, "last_update_time"
      # * -1 for desc
      (compare_metric x[0], y[0], value_a, value_b) * -1
    end
  end

  def metric_vote_count metric_name
    if (vote_count_card = Card[metric_name].fetch(trait: :vote_count))
      vote_count_card.content.to_i
    else
      0
    end
  end

  def sort_upvoted_desc metric_values
    metric_values.sort do |x, y|
      value_a = metric_vote_count(x[0])
      value_b = metric_vote_count(y[0])
      (compare_metric x[0], y[0], value_a, value_b) * -1
    end
  end

  def sort_value_count_desc metric_values
    metric_values.sort do |x, y|
      (compare_metric x[0], y[0], x[1].size, y[1].size) * -1
    end
  end

  def sorted_result sort_by, _order, _is_num=true
    cached_values = card.cached_values
    sorted = case sort_by
             when "value"
               sort_value_count_desc cached_values
             when "recent"
               sort_recent_desc cached_values
             else # upvoted
               sort_upvoted_desc cached_values
             end
    sorted
  end
end

format :html do
  def page_link_params
    [:name, :wikirate_topic, :research_policy, :vote, :value, :type,
     :year, :sort]
  end

  view :card_list_items do |args|
    search_results.map do |row|
      c = Card.fetch "#{row[0]}+#{card.cardname.left}"
      render :card_list_item, args.clone.merge(item_card: c)
    end.join "\n"
  end

  view :card_list_header do
    <<-HTML
      <div class='yinyang-row column-header'>
        <div class='company-item value-item'>
          <div class='metric-list-header slotter header'>
            Metrics
          </div>
          <div class='metric-list-header slotter data'>
            Values
          </div>
        </div>
      </div>
    HTML
  end

  view :metric_list do |_args|
    wrap_with :div, class: "yinyang-list" do
      render_content(hide: "title",
                     items: { view: :metric_row })
    end
  end
end
