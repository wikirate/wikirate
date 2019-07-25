include_set Abstract::Export

format :html do
  def export_link_path format
    super.merge filter_and_sort_hash
  end
end

format :json do
  view :compact, cache: :never do
    card.search.each_with_object(companies: {}, metrics: {}, answers: {}) do |ans, h|
      h[:companies][ans.company_id] ||= ans.company_name
      h[:metrics][ans.metric_id] ||= ans.metric_name
      h[:answers][answer_id(ans)] ||= {
        company: ans.company_id,
        metric: ans.metric_id,
        year: ans.year,
        value: ans.value
      }
    end
  end

  # prefix id with V (for virtual) if using id from answers table
  def answer_id answer
    answer.id || "V#{answer.answer.id}"
  end
end
