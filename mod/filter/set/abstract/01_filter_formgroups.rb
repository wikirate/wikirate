format :html do
  view :filter_check_formgroup, cache: :never do
    select_filter :check
  end

  view :filter_value_formgroup, cache: :never do
    text_filter :value
  end

  view :filter_project_formgroup, cache: :never do
    autocomplete_filter :project
    # select_filter_type_based :project
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
    text_filter :metric
  end

  view :filter_wikirate_company_formgroup, cache: :never do
    # select_filter_type_based :wikirate_company
    text_filter :wikirate_company
  end

  view :filter_research_policy_formgroup, cache: :never do
    multiselect_filter :research_policy
  end

  view :filter_metric_type_formgroup, cache: :never do
    multiselect_filter :metric_type
  end

  view :filter_status_formgroup, cache: :never do
    select_filter :status, "exists"
  end

  view :filter_updated_formgroup, cache: :never do
    select_filter :updated
  end

  view :filter_designer_formgroup, cache: :never do
    select_filter :designer
  end

  view :filter_importance_formgroup, cache: :never do
    multiselect_filter :importance, %w[upvotes novotes]
  end

  def default_year_option
    { "Most Recent" => "latest" }
  end

  def year_options
    type_options(:year, "desc").each_with_object(default_year_option) do |v, h|
      h[v] = v
    end
  end

  def updated_options
    { "today" => "today",
      "this week" => "week",
      "this month" => "month" }
  end

  def status_options
    {
      "All" => "all",
      "Researched" => "exists",
      "Known" => "known",
      "Unknown" => "unknown",
      "Not Researched" => "none"
    }
  end

  def metric_type_options
    %i[researched relationship formula wiki_rating score descendant].map do |codename|
      Card::Name[codename]
    end
  end

  def check_options
    %w[Completed Requested Neither]
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

  def designer_options
    metrics = Card.search type_id: MetricID, return: :name
    metrics.map do |m|
      names = m.to_name.parts
      # score metric?
      names.length == 3 ? names[2] : names[0]
    end.uniq(&:downcase).sort_by(&:downcase)
  end

  def status_filter_label
    "Status"
  end

  def value_filter_label
    "Value"
  end
end
