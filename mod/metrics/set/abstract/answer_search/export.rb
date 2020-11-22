include_set Abstract::Export

format :html do
  def export_link_path format
    super.merge filter_and_sort_hash
  end
end

format :json do
  view :compact, cache: :never do
    compact
  end

  def compact
    each_answer_with_hash do |answer, hash|
      hash[:companies][answer.company_id] ||= answer.company_name
      hash[:metrics][answer.metric_id] ||= answer.metric_name
      hash[:answers][answer.answer.flex_id] ||= answer.answer.compact_json
    end
  end

  view :compact_companies, cache: :never do
    answer_lookup.uniq.pluck(:company_id).map do |id|
      { id: id, name: id.cardname }
    end
  end

  view :answers_with_keys, cache: :never do
    answer_lookup.map do |answer|
      answer.compact_json.merge id: answer.flex_id, key: answer.name.url_key
    end
  end

  view :typed, cache: :never do
    compact.tap do |hash|
      id_and_name hash, :companies
      id_and_name hash, :metrics
      answer_array hash
    end
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

  def id_and_name hash, key
    hash[key] = hash[key].each_with_object([]) do |(id, name), array|
      array << { id: id, name: name }
    end
  end
end
