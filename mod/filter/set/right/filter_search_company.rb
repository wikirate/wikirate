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
  sort_by = Env.params["sort"] || "metric"
  search_args[:sort] = {
    right: sort_by, right_plus: "*cached count" }
  search_args[:sort_as] = "integer"
  search_args[:dir] = "desc"
  params[:query] = search_args
  super(params)
end

format :html do
  def page_link_params
    [:sort, :company, :industry, :project]
  end

  def default_filter_form_args args
    args[:formgroups] = [
      :sort_formgroup, :name_formgroup, :industry_formgroup, :project_formgroup
    ]
  end

  def default_name_formgroup_args args
    args[:name] = "company"
  end

  def default_sort_formgroup_args args
    args[:sort_options] = {
      "Most Metrics" => "metric", "Most Topics" => "topic"
    }
    args[:sort_option_default] = "metric"
  end
end
