include_set Abstract::Filter

def get_query params={}
  filter = params_to_hash %w(topic metric project wikirate_company)
  search_args = metric_wql filter
  params[:query] = search_args
  super(params)
end

def metric_wql opts, return_param=nil
  wql = { type_id: WikirateTopicID }
  wql[:return] = return_param if return_param
  filter_by_name wql, opts[:topic]
  filter_by_metric wql, opts[:metric]
  filter_by_company wql, opts[:wikirate_company]
  filter_by_project wql, opts[:project]
  puts wql.to_s.red
  wql
end

def filter_by_metric wql, metric
  return unless metric.present?
  wql[:referred_to_by] ||= []
  wql[:referred_to_by].push left: { name: metric }, right: "topic"
end

def filter_by_company wql, company
  return unless company.present?
  wql[:found_by] = "#{company}+topic"
end

def filter_by_project wql, project
  return unless project.present?
  wql[:referred_to_by] ||= []
  wql[:referred_to_by].push left: { name: project }, right: "topic"
end

format :html do
  def page_link_params
    [:sort, :topic, :metric, :wikirate_company, :project, :year]
  end

  def default_name_formgroup_args args
    args[:name] = "topic"
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
      :sort_formgroup, :name_formgroup, :metric_formgroup,
      :company_formgroup, :project_formgroup
    ]
  end
end
