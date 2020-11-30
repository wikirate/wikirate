include_set Abstract::Export

format :html do
  def export_link_path format
    super.merge filter_and_sort_hash
  end
end

format :json do
  view :compact, cache: :never do
    each_answer_with_hash do |answer, hash|
      hash[:companies][answer.company_id] ||= answer.company_name
      hash[:metrics][answer.metric_id] ||= answer.metric_name
      hash[:answers][answer.answer.flex_id] ||= answer.answer.compact_json
    end
  end

  view :company_list, cache: :never do
    map_unique :company_id do |id|
      { id: id, name: id.cardname }
    end
  end

  view :metric_list, cache: :never do
    map_unique :metric_id, :metric_type_id do |id, type_id|
      { id: id, name: id.card.metric_title, metric_type: type_id.cardname }
    end
  end

  view :answer_list, cache: :never do
    answer_lookup.map(&:compact_json)
  end

  view :keyed_answer_list, cache: :never do
    answer_lookup.map { |a| a.compact_json.merge key: a.name.url_key }
  end

  view :type_lists, cache: :never do
    {
      companies: render_company_list,
      metrics: render_metric_list,
      answers: render_answer_list
    }
  end

  view :year_list, cache: :never do
    AnswerQuery.new(filter_hash).year_counts
  end

  def answer_lookup
    query.answer_lookup
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
    answer_lookup.distinct.reorder(nil).pluck(*fields).map do |result|
      yield result
    end
  end
end
