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

def filter_by_key key
  super &&
    filter_by_research_policy(key) &&
    filter_by_metric_type(key)
end

format :json do
  view :core do
    card.item_cards(default_query: true)
        .each_with_object({}) do |metric_id, result|
      result[metric_id] = true unless result.key?(metric_id)
    end.to_json
  end
end
