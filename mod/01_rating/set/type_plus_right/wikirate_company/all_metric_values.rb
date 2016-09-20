include_set Abstract::AllValues

def wql_to_identify_related_metric_values
  '"left": { "right":"_left" }'
end

def key_type_id
  MetricID
end

def key_type
  :metric
end

def sort_params
  [(Env.params["sort"] || "upvoted"), "desc"]
end

def user_voted_metric votee_type
  votee_search = "#{Auth.current.name}+metric+#{votee_type}_search"
  Card.fetch(votee_search).item_names
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

  def sort_metric_designer metric_values
    metric_values.sort do |x, y|
      x[0] <=> y[0]
    end
  end

  def sort_metric_title metric_values
    metric_values.sort do |x, y|
      x[0].to_name.parts[1..-1] <=> y[0].to_name.parts[1..-1]
    end
  end

  def sorted_result sort_by, _order, _is_num=true
    cached_values = card.filtered_values_by_name
    return cached_values.to_a if %w(value recent).include? sort_by
    sorted = case sort_by
             when "value"
               sort_value_count_desc cached_values
             when "recent"
               sort_recent_desc cached_values
             when "metric_designer"
               sort_metric_designer cached_values
             when "metric_title"
               sort_metric_title cached_values
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
