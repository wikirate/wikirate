include_set Right::FilterSearch
include_set Right::MetricValueFilter
include_set Type::SearchType

def virtual?
  true
end

def raw_content
  %(
    {
      "left":{
        "type":"metric_value",
        "left":{
          "left":"_left"
        }
      },
      "right":"value",
      "limit":0
    }
  )
end

format :html do
  def page_link_params
    [:sort, :company, :industry, :project]
  end

  view :filter_form do |args|
    content = output([
                       optional_render(:sort_formgroup, args),
                       optional_render(:company_formgroup, args),
                       optional_render(:industry_formgroup, args),
                       optional_render(:project_formgroup, args)
                     ])
    action = card.left.name
    %( <form action="/#{action}" method="GET">#{content}</form>)
  end

  view :industry_formgroup do
    industries = Card[card.industry_metric_name].value_options
    options = options_for_select([["--", ""]] + industries,
                                 Env.params[:industry])
    multiselect_filter "industry", options
  end

  view :project_formgroup do
    projects = Card.search type_id: CampaignID, return: :name, sort: "name"
    options = options_for_select([["--", ""]] + projects, Env.params[:project])
    multiselect_filter "project", options
  end

  def multiselect_filter type_name, options
    multiselect_tag = select_tag(type_name, options,
                                 multiple: true, class: "pointer-multiselect")
    formgroup(type_name.capitalize, multiselect_tag,
              class: "filter-input #{type_name}")
  end

  view :sort_formgroup do |_args|
    options = {
      "Most Metrics" => "metric", "Most Topics" => "topic"
    }
    sort_param = params[:sort] || "metric"
    select_filter "sort", options_for_select(options, sort_param),
                  class: "filter-input"
  end
end
