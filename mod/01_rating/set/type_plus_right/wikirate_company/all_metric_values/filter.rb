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

def filter_by_topic metric
  return true unless Env.params["wikirate_topic"].present?
  topic_cards = Card[metric].fetch trait: :wikirate_topic
  topic_cards && topic_cards.item_names.include?(Env.params["wikirate_topic"])
end

def filter_by_vote metric
  vote_param = Env.params["my_vote"]
  return true if !vote_param.present? || vote_param.size == 3
  upvoted = upvoted_metric?(metric)
  downvoted = downvoted_metric?(metric)
  fit_vote? upvoted, downvoted, vote_param
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



