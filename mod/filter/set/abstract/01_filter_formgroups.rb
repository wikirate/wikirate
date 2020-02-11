format :html do
  view :filter_check_formgroup, cache: :never do
    select_filter :check
  end

  view :filter_value_formgroup, cache: :never do
    text_filter :value
  end

  view :filter_project_formgroup, cache: :never do
    autocomplete_filter :project
  end

  view :filter_year_formgroup, cache: :never do
    select_filter :year, "most recent"
  end

  view :filter_wikirate_topic_formgroup, cache: :never do
    multiselect_filter :wikirate_topic
  end

  view :filter_company_group_formgroup, cache: :never do
    multiselect_filter :company_group
  end

  view :filter_metric_name_formgroup, cache: :never do
    text_filter :metric_name
  end

  view :filter_company_name_formgroup, cache: :never do
    text_filter :company_name
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

  view :filter_outliers_formgroup, cache: :never do
    select_filter :outliers, "only"
  end

  view :filter_designer_formgroup, cache: :never do
    select_filter :designer
  end

  view :filter_bookmark_formgroup, cache: :never do
    select_filter :bookmark
  end

  view :filter_source_formgroup, cache: :never do
    autocomplete_filter :source
  end

  def default_year_option
    { "Latest" => "latest" }
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
    { "Researched - All" => "exists",
      "Researched - Known" => "known",
      "Researched - Unknown" => "unknown",
      "Not Researched" => "none",
      "Researched and Not" => "all" }
  end

  def outliers_options
    { "Only" => "only", "Exclude" => "exclude" }
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

  def company_group_options
    type_options :company_group
  end

  def bookmark_options
    { "I bookmarked" => :bookmark,
      "I did NOT bookmark" => :nobookmark }
  end

  def designer_options
    metrics = Card.search type_id: Card::MetricID, return: :name
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
