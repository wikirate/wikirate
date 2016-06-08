include_set Abstract::Filter

def get_query params={}
  filter = %w(company industry project).each_with_object({}) do |param, hash|
    if (val = Env.params[param])
      hash[param.to_sym] = val
    end
  end
  search_args = company_wql filter
  params[:query] = search_args
  super(params)
end

format :html do
  def page_link_params
    [:sort, :company, :industry, :project]
  end

  view :company_formgroup do
    text_filter "company", title: "Name"
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

  def select_filter type_name, options, args={}
    formgroup type_name.capitalize,
              select_tag(type_name, options, class: "pointer-select"),
              args
  end

  view :industry_formgroup do
    industries = Card[card.industry_metric_name].value_options
    options = options_for_select([["--", ""]] + industries,
                                 Env.params[:industry])
    select_filter "industry", options, class: "filter-input"
  end

  view :project_formgroup do
    projects = Card.search type_id: CampaignID, return: :name, sort: "name"
    options = options_for_select([["--", ""]] + projects, Env.params[:project])
    select_filter "project", options, class: "filter-input"
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
