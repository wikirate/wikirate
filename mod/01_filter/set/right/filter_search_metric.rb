include_set Abstract::Filter

def get_query params={}
  filter = params_to_hash %w(metric designer wikirate_topic project year)
  search_args = metric_wql filter
  sort_by search_args, Env.params["sort"]
  puts search_args.to_s.red
  params[:query] = search_args
  super(params)
end

def item_cards params={}
  s = query(params)
  raise("OH NO.. no limit") unless s[:limit]
  query = Query.new(s, comment)
  if %w(company values).include?(Env.params["sort"])
    # sort table alias always stick to the first table, but I need the next tabl
    sort = query.mods[:sort].scan(/c([\d+]).db_content/).last.first.to_i + 1
    query.mods[:sort] = "c#{sort}.db_content"
  end
  query.run
end

def metric_wql opts, return_param=nil
  wql = { type_id: MetricID }
  wql[:return] = return_param if return_param
  filter_by_name wql, opts[:metric]
  filter_by_designer wql, opts[:designer]
  filter_by_topic wql, opts[:wikirate_topic]
  filter_by_year wql, opts[:year]
  filter_by_project wql, opts[:project]
  wql
end

def sort_by wql, sort_by
  wql[:sort_as] = "integer"
  wql[:dir] = "desc"
  wql[:sort] =
    case sort_by
    when "values"
      { right: "value", right_plus: "*cached count" }
    when "recent"
      wql.delete :sort_as
      "update"
    when "company"
      { right: "company", right_plus: "*cached count" }
    else
      # upvoted as default
      { right: "*vote count" }
    end
end

def filter_by_topic wql, topic
  return unless topic.present?
  wql[:right_plus] ||= []
  wql[:right_plus].push ["topic", { refer_to: topic }]
end

def filter_by_project wql, project
  return unless project.present?
  wql[:referred_to_by] = { left: { name: project }, right: "metric" }
end

def filter_by_year wql, year
  return unless year.present?
  wql[:right_plus] ||= []
  wql[:right_plus].push [
    { type_id: Card::WikirateCompanyID },
    { right_plus: [{ name: year }, {}] }
  ]
end

def filter_by_designer wql, designer
  return unless designer.present?
  wql[:or] = {
    left: designer,
    right: designer
  }
end

format :html do
  def page_link_params
    [:sort, :metric, :designer, :wikirate_topic, :project, :year]
  end

  def default_name_formgroup_args args
    args[:name] = "metric"
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
