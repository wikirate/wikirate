format :html do
  view :filter_project_formgroup, cache: :never do
    select_filter_type_based :project
  end

  view :filter_year_formgroup, cache: :never do
    select_filter :year, "most recent"
  end

  view :filter_wikirate_topic_formgroup, cache: :never do
    multiselect_filter :wikirate_topic
    # autocomplete_filter :wikirate_topic
  end

  view :filter_metric_formgroup, cache: :never do
    # select_filter_type_based :metric
    autocomplete_filter :metric
  end

  view :filter_wikirate_company_formgroup, cache: :never do
    # select_filter_type_based :wikirate_company
    autocomplete_filter :wikirate_company
  end

  view :filter_research_policy_formgroup, cache: :never do
    multiselect_filter :research_policy
  end

  view :filter_metric_type_formgroup, cache: :never do
    multiselect_filter :metric_type
  end

  view :filter_metric_value_formgroup, cache: :never do
    select_filter :metric_value, "exists"
  end

  view :filter_designer_formgroup, cache: :never do
    select_filter :designer
  end

  view :filter_importance_formgroup, cache: :never do
    multiselect_filter :importance, %w[upvotes novotes]
  end

  view :filter_industry_formgroup, cache: :never do
    select_filter :industry
  end

  def default_year_option
    { "Most Recent" => "latest" }
  end

  def year_options
    type_options(:year, "desc").each_with_object(default_year_option) do |v, h|
      h[v] = v
    end
  end

  def metric_value_options
    opts = {
      "All" => "all",
      "Researched" => "exists",
      "Known" => "known",
      "Unknown" => "unknown",
      "Not Researched" => "none",
      "Edited today" => "today",
      "Edited this week" => "week",
      "Edited this month" => "month",
      "Outliers" => "outliers"
    }
    return opts unless filter_param(:range)
    opts.each_with_object({}) do |(k, v), h|
      h[add_range(k, v)] = v
    end
  end

  def add_range key, _value
    key # unless selected_value?(value)
    # range = filter_param :range
    # "#{range[:from]} <= #{key} < #{range[:to]}"
  end

  def selected_value? value
    (filter_param(:metric_value) && value == filter_param(:metric_value)) ||
      value == "exists"
  end

  def metric_type_options
    %i[researched relationship formula wiki_rating score descendant].map do |codename|
      Card::Name[codename]
    end
  end

  def research_policy_options
    type_options :research_policy
  end

  def wikirate_topic_options
    type_options :wikirate_topic
  end

  def importance_options
    { "I voted FOR" => :upvotes,
      "I voted AGAINST" => :downvotes,
      "I did NOT vote" => :novotes }
  end

  def industry_options
    card_name = CompanyFilterQuery::INDUSTRY_METRIC_NAME
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

  def metric_value_filter_label
    "Answer"
  end
end
