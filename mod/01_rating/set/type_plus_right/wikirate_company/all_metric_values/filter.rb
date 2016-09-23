def key_type_id
  MetricID
end

def filter_by_key key
  filter_by_metric key
end

def filter_by_values values
  filter_by_value(values) &&
    filter_by_year(values)
end

def filter_by_metric metric
  filter_by_name(metric) &&
    filter_by_topic(metric) &&
    filter_by_research_policy(metric) &&
    filter_by_vote(metric) &&
    filter_by_metric_type(metric)
end

def filter_by_vote metric
  keep_if :my_vote, options: 3 do |filter|
    case vote_status metric
    when :upvoted   then filter.include? "i voted for"
    when :downvoted then filter.include? "i voted against"
    else filter.include? "i did not vote"
    end
  end
end

private

def vote_status metric
  if upvoted_metric? metric
    :upvoted
  elsif downvoted_metric? metric
    :downvoted
  end
end

def upvoted_metric? metric
  @upvoted_metrics ||= ::Set.new user_voted_metric("upvotee")
  @upvoted_metrics.include? metric
end

def downvoted_metric? metric
  @downvoted_metrics ||= ::Set.new user_voted_metric("downvotee")
  @downvoted_metrics.include? metric
end

def user_voted_metric votee_type
  votee_search = "#{Auth.current.name}+metric+#{votee_type}_search"
  Card.fetch(votee_search).item_names
end