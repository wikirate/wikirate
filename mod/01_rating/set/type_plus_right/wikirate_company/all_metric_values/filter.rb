def key_type_id
  MetricID
end

def filter_by_key key
  filter_by_metric key
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
    rp_card.item_names.any? { |s| s.casecmp(research_policy[0]).zero? }
end

def filter_by_vote metric
  vote_param = Env.params["my_vote"]
  return true if !vote_param.present? || vote_param.size == 3
  upvoted = upvoted_metric?(metric)
  downvoted = downvoted_metric?(metric)
  fit_vote? upvoted, downvoted, vote_param
end

def filter_by_type metric
  return true unless Env.params["type"].present?
  return false if Card[metric].type_id != MetricID
  mt = Card[metric].metric_type
  Env.params["type"].any? { |s| s.casecmp(mt).zero? }
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

private

def fit_vote? upvoted, downvoted, vote_param
  not_voted = !upvoted && !downvoted
  result = false
  result |= upvoted if vote_param.include?("i voted for")
  result |= downvoted if vote_param.include?("i voted against")
  result |= not_voted if vote_param.include?("i did not vote")
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
    3600
  when "today"
    86_400
  when "week"
    604_800
  when "month"
    2_592_000
  end
end
