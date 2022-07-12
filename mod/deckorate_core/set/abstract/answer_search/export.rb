include_set Abstract::Export

# format :html do
#   def export_link_path_args format
#     super.merge filter_and_sort_hash
#   end
# end

format :json do
  view :compact, cache: :never do
    each_answer_with_hash do |answer, hash|
      hash[:companies][answer.company_id] ||= answer.company_name
      hash[:metrics][answer.metric_id] ||= answer.metric_name
      hash[:answers][answer.answer.flex_id] ||= answer.answer.compact_json
    end
  end

  view :company_list, cache: :never do
    list_of_hashes = map_unique(:company_id) { |id| { id: id, name: id.cardname } }
    list_of_hashes.sort_by { |h| h[:name] }
  end

  view :metric_list, cache: :never do
    map_unique :metric_id, :metric_type_id do |id, type_id|
      { id: id, name: id.card.metric_title, metric_type: type_id.cardname }
    end
  end

  view :answer_list, cache: :never do
    lookup_relation.map(&:compact_json)
  end

  view :keyed_answer_list, cache: :never do
    lookup_relation.map { |a| a.compact_json.merge key: a.name.url_key }
  end

  view :type_lists, cache: :never do
    {
      companies: render_company_list,
      metrics: render_metric_list,
      answers: render_answer_list
    }
  end

  view :metric_type_counts, cache: :never do
    grouped_counts :metric_type_id
  end

  view :value_type_counts, cache: :never do
    grouped_counts :value_type_id
  end

  view :verification_counts, cache: :never do
    grouped_counts :verification
  end

  def grouped_counts subgroup
    lookup_query.joins(:metric).group(:year, subgroup).count.map do |array, count|
      { count: count, year: array.first, subgroup: array.last }
    end
  end

  def answer_array hash
    hash[:answers] = hash[:answers].each_with_object([]) do |(key, val), array|
      array << val.merge(id: key)
    end
  end

  def each_answer_with_hash
    search_with_params.each_with_object(
      companies: {}, metrics: {}, answers: {}
    ) do |answer, hash|
      yield answer, hash
    end
  end

  def map_unique *fields
    lookup_query.joins(:metric).distinct.limit(1000).pluck(*fields).map do |result|
      yield result
    end
  end
end
