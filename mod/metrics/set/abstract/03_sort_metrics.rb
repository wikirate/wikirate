format do
  def sort_by
    @sort_by ||= Env.params["sort"] || "upvoted"
  end

  def sort_order
    "desc"
  end

  def sort values
    return values.to_a if %w[value recent].include? sort_by
    case sort_by
    when "value"
      sort_value_count_desc values
    when "recent"
      sort_recent_desc values
    when "metric_designer"
      sort_metric_designer values
    when "metric_title"
      sort_metric_title values
    else # upvoted
      sort_upvoted_desc values
    end
  end

  def sort_recent_desc metric_values
    metric_values.sort do |x, y|
      value_a = latest_row_value x, "last_update_time"
      value_b = latest_row_value y, "last_update_time"
      # * -1 for desc
      (compare_metric x[0], y[0], value_a, value_b) * -1
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

  def sort_metric_designer metric_values
    metric_values.sort_by { |a| a[0] }
  end

  def sort_metric_title metric_values
    metric_values.sort do |x, y|
      x[0].to_name.parts[1..-1] <=> y[0].to_name.parts[1..-1]
    end
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

  def latest_row_value row, key
    row[1].sort_by { |value| value[key] }.reverse[0][key]
  end

  def metric_vote_count metric_name
    return 0 unless (metric_card = Card[metric_name])
    return 0 unless (vote_count_card = metric_card.fetch trait: :vote_count)
    vote_count_card.content.to_i
  end

  def vote_status metric
    @upvoted_metric ||= card.user_voted_metric "upvotee"
    @downvoted_metric ||= card.user_voted_metric "downvotee"
    return :upvoted if @upvoted_metric.include?(metric)
    return :downvoted if @downvoted_metric.include?(metric)
    :none
  end
end

def user_voted_metric votee_type
  votee_search = "#{Auth.current.name}+metric+#{votee_type}_search"
  Card.fetch(votee_search).item_names
end
