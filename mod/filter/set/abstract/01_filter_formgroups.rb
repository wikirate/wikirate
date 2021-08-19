format :html do
  view :filter_verification_formgroup, cache: :never do
    select_filter :verification
  end

  view :filter_updater_formgroup, cache: :never do
    select_filter :updater
  end

  view :filter_value_formgroup, cache: :never do
    text_filter :value
  end

  view :filter_project_formgroup, cache: :never do
    autocomplete_filter :project
  end

  view :filter_year_formgroup, cache: :never do
    select_filter :year
  end

  view :filter_wikirate_topic_formgroup, cache: :never do
    multiselect_filter :wikirate_topic
  end

  view :filter_calculated_formgroup, cache: :never do
    select_filter :calculated
  end

  view :filter_company_group_formgroup, cache: :never do
    multiselect_filter :company_group
  end

  view :filter_country_formgroup, cache: :never do
    multiselect_filter :country
  end

  view :filter_company_name_formgroup, cache: :never do
    text_filter :company_name
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

  view :filter_bookmark_formgroup, cache: :never do
    select_filter :bookmark
  end

  view :filter_source_formgroup, cache: :never do
    autocomplete_filter :source
  end

  view :filter_published_formgroup, cache: :never do
    select_filter :published, "true"
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
      "Researched - Unknown" => "unknown" }
  end

  def outliers_options
    { "Only" => "only", "Exclude" => "exclude" }
  end

  def verification_options
    standard_verification_options.tap do |opts|
      verified_by_me_option opts
      verified_by_wikirate_team opts
    end
  end

  def standard_verification_options
    Answer::VERIFICATION_LEVELS.map.with_object({}) do |level, opts|
      opts[level[:title]] = level[:name]
    end
  end

  def verified_by_me_option opts
    opts["Verified by Me"] = "current_user" if Card::Auth.signed_in?
  end

  def verified_by_wikirate_team opts
    opts["Verified by WikiRate Team"] = "wikirate_team" if Self::WikirateTeam.member?
  end

  def updater_options
    o = {}
    o["by Me"] = "current_user" if Card::Auth.signed_in?
    o["by WikiRate Team"] = "wikirate_team" if Self::WikirateTeam.member?
    o
  end

  def wikirate_topic_options
    type_options :wikirate_topic
  end

  def company_group_options
    type_options :company_group
  end

  def country_options
    Card::Region.countries
  end

  def bookmark_options
    { "I bookmarked" => :bookmark,
      "I did NOT bookmark" => :nobookmark }
  end

  def calculated_options
    { "Yes" => :calculated, "No" => :not_calculated }
  end

  def status_filter_label
    "Status"
  end

  def value_filter_label
    "Value"
  end

  def published_options
    {
      "Published only"   => "true",
      "Unpublished only" => "false",
      "Either"           => "all"
    }
  end
end
