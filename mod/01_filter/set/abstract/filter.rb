include_set Type::SearchType

def sort?
  true
end

def shift_sort_table?
  true
end

def default_sort_by_key
  "metric"
end

def params_keys
  %w(metric designer wikirate_topic project year)
end

def get_query params={}
  filter = params_to_hash params_keys
  search_args = search_wql filter
  sort_by search_args, Env.params["sort"] if sort?
  params[:query] = search_args
  super(params)
end

def item_cards params={}
  s = query(params)
  raise("OH NO.. no limit") unless s[:limit]
  query = Query.new(s, comment)
  shift_sort_table query
  query.run
end

def shift_sort_table query
  if sort? && shift_sort_table?
    # sort table alias always stick to the first table,
    # but I need the next table
    sort = query.mods[:sort].scan(/c([\d+]).db_content/).last.first.to_i + 1
    query.mods[:sort] = "c#{sort}.db_content"
  end
end

def sort_by wql, sort_by
  wql[:sort_as] = "integer"
  wql[:dir] = "desc"
  wql[:sort] = {
    right: (sort_by || default_sort_by_key), right_plus: "*cached count" }
end

def virtual?
  true
end

def raw_content
  %(
    {
      "name":"dummy"
    }
  )
end

def params_to_hash params
  params.each_with_object({}) do |param, hash|
    if (val = Env.params[param])
      hash[param.to_sym] = val
    end
  end
end

def search_wql opts, return_param=nil
  wql = { type_id: WikirateCompanyID }
  wql[:return] = return_param if return_param
  filter_by_name wql, opts[:company] if opts[:company].present?
  filter_by_industry wql, opts[:industry] if opts[:industry].present?
  filter_by_project wql, opts[:project] if opts[:project].present?
  wql
end

def filter_by_name wql, name
  return unless name.present?
  wql[:name] = ["match", name]
end

def filter_by_project wql, project
  wql[:referred_to_by] = { left: { name: project } }
end

def filter_by_industry wql, industry
  wql[:left_plus] = [
    format.industry_metric_name,
    { right_plus: [
      format.industry_value_year,
      { right_plus: ["value", { eq: industry }] }
    ] }
  ]
end

format :html do
  def industry_metric_name
    "Global Reporting Initiative+Sector Industry"
  end

  def industry_value_year
    "2015"
  end

  def page_link_params
    []
  end

  view :no_search_results do |_args|
    %(
      <div class="search-no-results">
        No result
      </div>
    )
  end

  view :filter_form do |args|
    formgroups = args[:formgroups] || [:name_formgroup]
    html = formgroups.map do |fg|
      optional_render(fg, args)
    end
    content = output(html)
    action = card.left.name
    %( <form action="/#{action}" method="GET">#{content}</form>)
  end

  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    filter_args = {}
    page_link_params.each do |key|
      filter_args[key] = params[key] if params[key].present?
    end
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    link_to raw(text), path(@paging_path_args.merge(filter_args)), options
  end

  def text_filter type_name, args
    formgroup args[:title] || type_name.capitalize,
              text_field_tag(type_name, params[type_name],
                             class: "form-control"),
              class: " filter-input"
  end

  def type_options type_codename
    type_card = Card[type_codename]
    Card.search type_id: type_card.id, return: :name, sort: "name"
  end

  def select_filter type_codename, label=nil
    label ||= type_codename.to_s.capitalize
    options = type_options type_codename
    options.unshift(["--", ""])
    simple_select_filter type_codename.to_s, options, Env.params[type_codename],
                         label
  end

  def simple_select_filter type_name, options, default, label=nil
    options = options_for_select(options, default)
    label ||= type_name.capitalize
    formgroup label, select_tag(type_name, options, class: "pointer-select"),
              class: "filter-input "
  end

  def simple_multiselect_filter type_name, options, default, label=nil
    options = options_for_select(options, default)
    label ||= type_name.capitalize
    multiselect_tag = select_tag(type_name, options,
                                 multiple: true,
                                 class: "pointer-multiselect")
    formgroup(label, multiselect_tag, class: "filter-input #{type_name}")
  end

  def multiselect_filter type_codename, label=nil
    options = type_options type_codename
    label ||= type_codename.to_s
    simple_multiselect_filter type_codename.to_s, options,
                              Env.params[type_codename], label
  end

  view :name_formgroup do |args|
    name = args[:name] || "Name"
    text_filter name, title: "Name"
  end

  view :project_formgroup do
    select_filter :project
  end

  view :year_formgroup do
    select_filter :year
  end

  view :topic_formgroup do
    select_filter :wikirate_topic, "Topic"
  end

  view :metric_formgroup do
    select_filter :metric
  end

  view :company_formgroup do
    select_filter :wikirate_company, "Company"
  end

  view :metric_value_formgroup do
    options = {
      "Exists" => "exists",
      "None" => "none",
      "Edited in last hour" => "last_hour",
      "Edited today" => "today",
      "Edited this week" => "week",
      "Edited this month" => "month"
    }
    simple_select_filter "value", options, "exists"
  end

  view :metric_type_formgroup do
    type_card = Card["metric_type"]
    options = Card.search type_id: type_card.id, return: :name, sort: "name"
    checkboxes = options.map do |option|
      checked = Env.params["metric_type"].present? &&
                Env.params["metric_type"].include?(option.downcase)
      %(<label>
        #{check_box_tag('metric_type[]', option.downcase, checked) + option}
      </label>)
    end
    formgroup "Type", checkboxes.join("")
  end

  view :research_policy_formgroup do
    select_filter :research_policy, "Research Policy"
  end

  view :designer_formgroup do
    metrics = Card.search type_id: MetricID, return: :name
    designers = metrics.map do |m|
      names = m.to_name.parts
      # score metric?
      names.length == 3 ? names[2] : names[0]
    end.uniq!
    simple_select_filter "designer", [["--", ""]] + designers,
                         Env.params[:designer]
  end

  view :importance_formgroup do
    options = {
      "All" => "all",
      "Upvoted by me" => "upvotee",
      "Downvoted by me" => "downvotee"
    }
    simple_select_filter "vote", options, Env.params["vote"] || "all"
  end

  view :industry_formgroup do
    industries = Card[industry_metric_name].value_options
    simple_select_filter "industry", [["--", ""]] + industries,
                         Env.params[:industry]
  end

  view :sort_formgroup do |args|
    options = args[:sort_options] || {}
    sort_param = Env.params[:sort] || args[:sort_option_default]
    simple_select_filter "sort", options_for_select(options, sort_param),
                         class: "filter-input"
  end
end
