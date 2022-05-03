WIKIRATE_FILTER_TYPES = {
  verification: :select,
  updater: :select,
  value: :text,
  dataset: :autocomplete,
  year: :multi,
  wikirate_topic: :multi,
  calculated: :select,
  company_group: :multi,
  company_name: :text,
  country: :multi,
  status: :select,
  bookmark: :select,
  updated: :select,
  outliers: :select,
  source: :autocomplete,
  published: :select
}

format :html do
  WIKIRATE_FILTER_TYPES.each do |filter_key, filter_type|
    define_method("filter_#{filter_key}_type") { filter_type }
  end

  def filter_status_default
    "exists"
  end

  def filter_outliers_default
    "only"
  end

  def filter_published_default
    "true"
  end

  def filter_year_options
    type_options(:year, "desc").each_with_object("Latest" => "latest") do |v, h|
      h[v] = v
    end
  end

  def filter_updated_options
    { "today" => "today",
      "this week" => "week",
      "this month" => "month" }
  end

  def filter_status_options
    { "Researched - All" => "exists",
      "Researched - Known" => "known",
      "Researched - Unknown" => "unknown" }
  end

  def filter_outliers_options
    { "Only" => "only", "Exclude" => "exclude" }
  end

  def filter_verification_options
    standard_verification_options.tap do |opts|
      verified_by_me_option opts
      verified_by_wikirate_team opts
    end
  end

  def filter_updater_options
    o = {}
    o["by Me"] = "current_user" if Card::Auth.signed_in?
    o["by WikiRate Team"] = "wikirate_team" if Self::WikirateTeam.member?
    o
  end

  def filter_wikirate_topic_options
    type_options :wikirate_topic
  end

  def filter_company_group_options
    type_options :company_group
  end

  def filter_country_options
    Card::Region.countries
  end

  def filter_bookmark_options
    { "I bookmarked" => :bookmark,
      "I did NOT bookmark" => :nobookmark }
  end

  def filter_calculated_options
    { "Yes" => :calculated, "No" => :not_calculated }
  end

  def filter_status_label
    "Status"
  end

  def filter_value_label
    "Value"
  end

  def filter_published_options
    {
      "Published only"   => "true",
      "Unpublished only" => "false",
      "Either"           => "all"
    }
  end

  private

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
end
