include_set Abstract::FilterFormHelper

format :html do
  view :name_formgroup do
    text_filter :name
  end

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

  view :metric_type_formgroup do
    checkbox_filter :metric_type, metric_type_filter_options
  end

  def metric_type_select
    options = metric_type_filter_options
    options.unshift(["--", ""])
    simple_select_filter :metric_type, options,
                         filter_param(:metric_type),
                         "Metric Type"
  end

  def metric_type_filter_options
    [:researched, :formula, :wiki_rating].map { |n| Card.quick_fetch(n).name }
  end

  view :research_policy_formgroup do
    options = type_options :research_policy
    checkbox_filter "Research Policy", options
  end

  def research_policy_select
    select_filter :research_policy, "asc"
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
    simple_select_filter :value, options, "exists"
  end

  view :designer_formgroup do
    simple_select_filter :designer, [["--", ""]] + all_metric_designers, nil,
                         "Designer"
  end

  view :importance_formgroup do
    options = ["I voted FOR", "I voted AGAINST", "I did NOT vote"]
    checkbox_filter "My Vote", options, ["i voted for", "i did not vote"]
  end

  view :industry_formgroup do
    simple_select_filter :industry, [["--", ""]] + industry_options,
                         nil, "Industry"
  end

  view :sort_formgroup do
    selected_option = Env.params[:sort] || default_sort_option
    options = options_for_select(sort_options, selected_option)
    formgroup "Sort", class: "filter-input " do
      select_tag "sort", options
    end
  end

  def sort_options
    {}
  end

  def industry_options
    card_name = Right::BrowseCompanyFilter::CompanyFilter::INDUSTRY_METRIC_NAME
    Card[card_name].value_options
  end

  def all_metric_designers
    metrics = Card.search type_id: MetricID, return: :name
    metrics.map do |m|
      names = m.to_name.parts
      # score metric?
      names.length == 3 ? names[2] : names[0]
    end.uniq!(&:downcase).sort_by!(&:downcase)
  end
end
