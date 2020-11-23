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
    unique_id_and_name :company_id
  end

  view :metric_list, cache: :never do
    unique_id_and_name :metric_id
  end

  view :answer_list, cache: :never do
    answer_lookup.map { |a| a.compact_json }
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

  def unique_id_and_name field
    answer_lookup.distinct.reorder(nil).pluck(field).map do |id|
      { id: id, name: id.cardname }
    end
  end
end
