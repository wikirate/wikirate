include_set Abstract::Filter
include_set Type::SearchType

def virtual?
  true
end

def get_query params={}
  filter = params_to_hash %w(metric desinger topic project year)
  search_args = metric_wql filter
  sort_by = Env.params["sort"] || "metric"
  search_args[:sort] = {
    right: sort_by, right_plus: "*cached count" }
  search_args[:sort_as] = "integer"
  search_args[:dir] = "desc"
  params[:query] = search_args
  super(params)
end

def metric_wql opts, return_param=nil
  wql = { type_id: MetricID }
  wql[:return] = return_param if return_param
  filter_by_name wql, opts[:metric] if opts[:metric].present?
  filter_by_desinger wql, opts[:desinger]
  filter_by_topic wql, opts[:topic]
  filter_by_year wql, opts[:year]
  filter_by_project wql, opts[:project]
  wql
end

def filter_by_desinger wql, industry
  return unless desinger.nil?
  filter = left.fetch(trait: :metric_value_filter)
  wql[:left_plus] = [
    filter.industry_metric_name,
    { right_plus: [
      filter.industry_value_year,
      { right_plus: ["value", { eq: industry }] }
    ] }
  ]
end

format :html do
  def page_link_params
    [:sort, :metric, :designer, :topic, :project, :year]
  end

  view :sort_formgroup do |_args|
    options = {
      "Most Upvoted" => "upvoted",
      "Most Recent" => "recent",
      "Most Companies" => "company",
      "Most Values" => "values"
    }
    sort_param = params[:sort] || "metric"
    select_filter "sort", options_for_select(options, sort_param),
                  class: "filter-input"
  end

  view :metric_formgroup do
    @metrics ||= Card.search type_id: MetricID, return: :name, sort: "name"
    options = options_for_select([["--", ""]] + @metrics, Env.params[:metric])
    select_filter "metric", options, class: "filter-input"
  end

  view :designer_formgroup do
    @metrics ||= Card.search type_id: MetricID
    designers =
      @metrics.map do |m|
        names = m.to_name.parts
        # score metric?
        names.length == 3 ? names[2] : names [0]
      end.uniq!
    options = options_for_select([["--", ""]] + designers,
                                 Env.params[:designer])
    select_filter "designer", options, class: "filter-input"
  end

  view :topic_formgroup do
    topics = Card.search type_id: WikirateTopicID, return: :name, sort: "name"
    options = options_for_select([["--", ""]] + topics, Env.params[:topic])
    select_filter "topic", options, class: "filter-input"
  end

  view :year_formgroup do |_args|
    options = Card.search(
      type_id: YearID, return: :name, sort: "name", dir: "desc"
    )
    filter_options = options_for_select([["--", ""]] + options,
                                        params[:year] || "all")
    select_filter "year", filter_options
  end

  view :filter_form do |args|
    content = output([
                       optional_render(:sort_formgroup, args),
                       optional_render(:metric_formgroup, args),
                       optional_render(:designer_formgroup, args),
                       optional_render(:topic_formgroup, args),
                       optional_render(:project_formgroup, args),
                       optional_render(:year_formgroup, args)
                     ])
    action = card.left.name
    %( <form action="/#{action}" method="GET">#{content}</form>)
  end
end
