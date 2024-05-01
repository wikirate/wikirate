include_set Abstract::FullAnswerSearch
include_set Abstract::Chart
include_set Abstract::CachedCount

def count
  Card::AnswerQuery.new({}).count
end

# recount answers when answer is created or deleted
recount_trigger :type, :metric_answer, on: %i[create delete] do |_changed_card|
  :metric_answer.card
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |_changed_card|
  :metric_answer.card
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :metric_answer, :unpublished do |_changed_card|
  :metric_answer.card
end

format do
  def counts
    return super unless @counts.blank? && default_filter?

    @counts = Card.cache.fetch("ANSWER-COUNTS-CACHE-#{hourly_cache_stamp}") { super }
  end

  def default_filter?
    filter_hash_from_params.blank? || (filter_hash == default_filter_hash)
  end

  def hourly_cache_stamp
    Time.now.strftime "%y%m%d%H"
  end
end

format :html do
  def default_sort_option
    :year
  end

  view :titled_content do
    [field_nest(:description), render_filtered_content]
  end
end

format :json do
  def grouped_counts subgroup
    return super unless subgroup == :verification && default_filter?

    Card.cache.fetch("VERIFICATION-GROUPS-CACHE-#{hourly_cache_stamp}") { super }
  end

  def default_vega_options
    { layout: { width: 700 } }
  end
end
