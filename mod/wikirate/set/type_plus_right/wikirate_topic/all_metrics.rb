include_set Abstract::SortAndFilter

def raw_content
  %({
      "type_id":#{MetricID},
      "right_plus":[
        "topic", { "refer_to":"_left"}
      ],
      "return":"id",
      "limit":0
    })
end

def pass_filter? metric, _values
  filter_by_name(metric) &&
    filter_by_research_policy(metric) &&
    filter_by_type(metric)
end

format :json do
  view :core do
    item_cards(default_query: true).each_with_object({}) do |metric_id, result|
      result[metric_id] = true unless result.key?(metric_id)
    end.to_json
  end
end

format do
  def sort_by
    @sort_by ||= Env.params["sort"] || "upvoted"
  end

  def sort_order
    "desc"
  end

  def sorted_result
    cached_values = card.filtered_values_by_name
    if sort_by == "company_number"
      sort_company_number_desc cached_values
    else
      super
    end
  end

  def metric_company_count metric
    metric_company = Card[metric].fetch trait: :wikirate_company
    metric_company_count = metric_company.fetch trait: :cached_count, new: {}
    metric_company_count.format.render_core.to_i
  end

  def sort_company_number_desc metrics
    metrics.sort do |x, y|
      metric_company_count(y[0]) - metric_company_count(x[0])
    end
  end

  def page_link_params
    [:name, :research_policy, :type, :sort]
  end
end
