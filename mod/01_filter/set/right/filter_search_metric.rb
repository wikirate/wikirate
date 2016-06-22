include_set Abstract::Filter

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
  filter_by_designer wql, opts[:designer]
  filter_by_topic wql, opts[:topic]
  filter_by_year wql, opts[:year]
  filter_by_project wql, opts[:project]
  wql
end

def filter_by_designer wql, designer
  return unless designer.nil?
  filter = left.fetch(trait: :metric_value_filter)
  wql[:left_plus] = [
    filter.industry_metric_name,
    { right_plus: [
      filter.industry_value_year,
      { right_plus: ["value", { eq: designer }] }
    ] }
  ]
end

format :html do
  def page_link_params
    [:sort, :metric, :designer, :wikirate_topic, :project, :year]
  end

  def default_name_formgroup_args args
    args[:name] = "Metric"
  end

  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Most Upvoted" => "upvoted",
      "Most Recent" => "recent",
      "Most Companies" => "company",
      "Most Values" => "values"
    }
    args[:sort_option_default] = "upvoted"
  end

  def default_filter_form_args args
    args[:formgroups] = [
      :sort_formgroup, :name_formgroup, :designer_formgroup,
      :topic_formgroup, :project_formgroup, :year_formgroup
    ]
  end
end
