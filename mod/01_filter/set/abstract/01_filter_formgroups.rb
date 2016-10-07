include_set Abstract::FilterFormHelper

format :html do
  view :project_formgroup do
    select_filter :project, "asc"
  end

  view :year_formgroup do
    select_filter :year, "desc"
  end

  view :wikirate_topic_formgroup do
    select_filter :wikirate_topic, "asc"
  end

  view :metric_formgroup do
    select_filter :metric, "asc"
  end

  view :wikirate_company_formgroup do
    select_filter :wikirate_company, "asc"
  end

  view :metric_type_formgroup do |args|
    options = metric_type_filter_options.map { |n| Card.quick_fetch(n).name }
    if args[:select_list]
      options.unshift(["--", ""])
      simple_select_filter :metric_type, options,
                           filter_value_from_params(:metric_type),
                           "Metric Type"
    else
      checkbox_filter "Type", options
    end
  end

  def metric_type_filter_options
    [:researched, :formula, :wiki_rating]
  end

  view :research_policy_formgroup do |args|
    if args[:select_list]
      select_filter :research_policy, "asc"
    else
      options = type_options :research_policy
      checkbox_filter "Research Policy", options
    end
  end

  view :metric_value_formgroup do
    options = {
      "All" => "all",
      "Researched" => "exists",
      "Not Researched" => "none",
      "Edited today" => "today",
      "Edited this week" => "week",
      "Edited this month" => "month",
      "Outliers" => "outliers"
    }
    simple_select_filter "value", options, (Env.params["value"] || "exists")
  end


  def filter_value_from_params category
    Env.params[:filter][category]
  end

  view :designer_formgroup do
    metrics = Card.search type_id: MetricID, return: :name
    designers = metrics.map do |m|
      names = m.to_name.parts
      # score metric?
      names.length == 3 ? names[2] : names[0]
    end.uniq!(&:downcase).sort_by!(&:downcase)
    simple_select_filter "designer", [["--", ""]] + designers,
                         Env.params[:designer]
  end


  view :importance_formgroup do
    options = ["I voted FOR", "I voted AGAINST", "I did NOT vote"]
    checkbox_filter "My Vote", options, ["i voted for", "i did not vote"]
  end

  view :industry_formgroup do
    industries = Card[card.industry_metric_name].value_options
    simple_select_filter "industry", [["--", ""]] + industries,
                         Env.params[:industry]
  end

  view :sort_formgroup do |args|
    options = args[:sort_options] || {}
    sort_param = Env.params[:sort] || args[:sort_option_default]
    select_filter_html "sort", options_for_select(options, sort_param),
                       nil, nil, true
  end
end