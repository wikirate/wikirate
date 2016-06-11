include_set Abstract::Filter

def item_cards params={}
  s = query(params)
  raise("OH NO.. no limit") unless s[:limit]
  query = Query.new(s, comment)
  # sort table alias always stick to the first table, but I need the next table
  sort = query.mods[:sort].scan(/c([\d+]).db_content/).last.first.to_i + 1
  query.mods[:sort] = "c#{sort}.db_content"
  query.run
end

def get_query params={}
  filter = params_to_hash %w(company industry project)
  search_args = company_wql filter
  search_args[:sort] = {
    right: Env.params["sort"], right_plus: "*cached count" }
  search_args[:sort_as] = "integer"
  search_args[:dir] = "desc"
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
