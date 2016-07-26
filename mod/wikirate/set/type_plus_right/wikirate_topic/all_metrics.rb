include_set TypePlusRight::WikirateCompany::AllMetricValues
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

def sort_params
  [(Env.params["sort"] || "upvoted"), "desc"]
end

def cached_values
  @cached_metric_values ||= get_cached_values
  if @cached_metric_values
    result = @cached_metric_values.select do |metric, _values|
      filter metric
    end
    result
  else
    @cached_metric_values
  end
end

def filter metric
  filter_by_name(metric) &&
    filter_by_research_policy(metric) &&
    filter_by_type(metric)
end

format :html do
  def page_link_params
    [:name, :research_policy, :type, :sort]
  end

  view :card_list_items do |args|
    search_results.map do |row|
      c = Card.fetch row[0]
      render :card_list_item, args.clone.merge(item_card: c)
    end.join "\n"
  end

  view :card_list_header do
    ""
  end

  view :metric_list do |_args|
    wrap_with :div, class: "yinyang-list" do
      render_content(hide: "title",
                     items: { view: :metric_row })
    end
  end
end
