include_set Abstract::FilterFormHelper

format :html do
  view :name_formgroup, cache: :never do
    text_filter :name
  end

  view :project_formgroup, cache: :never do
    select_filter_type_based :project
  end

  view :year_formgroup, cache: :never do
    select_filter_type_based :year
  end

  view :wikirate_topic_formgroup, cache: :never do
    select_filter_type_based :wikirate_topic
  end

  view :metric_formgroup, cache: :never do
    select_filter_type_based :metric
  end

  view :wikirate_company_formgroup, cache: :never do
    select_filter_type_based :wikirate_company
  end

  view :research_policy_formgroup, cache: :never do
    checkbox_filter :research_policy, "Research Policy"
  end

  def research_policy_select
    select_filter_type_based :research_policy
  end

  view :metric_type_formgroup, cache: :never do
    checkbox_filter :metric_type, "Metric Type"
  end

  def metric_type_select
    select_filter :metric_type, "Metric Type"
  end

  view :metric_value_formgroup, cache: :never do
    select_filter :metric_value, "Value", "exists"
  end

  view :designer_formgroup, cache: :never do
    select_filter :designer, "Designer"
  end

  view :importance_formgroup do
    checkbox_filter :importance, "My Vote", ["i voted for", "i did not vote"]
  end

  view :industry_formgroup do
    select_filter :industry, "Industry"
  end

  view :sort_formgroup do
    selected_option = sort_param || default_sort_option
    options = options_for_select(sort_options, selected_option)
    formgroup "Sort", class: "filter-input " do
      select_tag "sort", options, class: "pointer-select"
    end
  end

  def sort_options
    {}
  end

  def metric_value_options
    {
        "All" => "all",
        "Researched" => "exists",
        "Not Researched" => "none",
        "Edited today" => "today",
        "Edited this week" => "week",
        "Edited this month" => "month",
        "Outliers" => "outliers"
    }
  end

  def metric_type_options
    [:researched, :formula, :wiki_rating].map { |n| Card.quick_fetch(n).name }
  end

  def research_policy_options
    type_options :research_policy
  end

  def importance_options
    ["I voted FOR", "I voted AGAINST", "I did NOT vote"]
  end

  def industry_options
    card_name =
      Right::BrowseCompanyFilter::CompanyFilterQuery::INDUSTRY_METRIC_NAME
    Card[card_name].value_options
  end

  def designer_options
    metrics = Card.search type_id: MetricID, return: :name
    metrics.map do |m|
      names = m.to_name.parts
      # score metric?
      names.length == 3 ? names[2] : names[0]
    end.uniq!(&:downcase).sort_by!(&:downcase)
  end
end
