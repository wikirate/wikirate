include_set Abstract::FullAnswerSearch
include_set Abstract::Chart
include_set Abstract::CachedCount

def count
  Card::AnswerQuery.new({}).count
end

def count_label
  "Data points"
end

# recount answers when answer is created or deleted
recount_trigger :type, :answer, on: %i[create delete] do |_changed_card|
  :answer.card
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |_changed_card|
  :answer.card
end

# ...or when answer is (un)published
field_recount_trigger :type_plus_right, :answer, :unpublished do |_changed_card|
  :answer.card
end

format do
  def standard_title
    "Data points"
  end

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
  view :titled_content do
    [field_nest(:description), render_filtered_content]
  end

  view :filtered_results_footer do
    export_form
  end
end

format :json do
  def grouped_counts subgroup
    return super unless subgroup == :verification && default_filter?

    Card.cache.fetch("VERIFICATION-GROUPS-CACHE-#{hourly_cache_stamp}") { super }
  end

  def default_vega_options
    { layout: { width: 1000 } }
  end
end
