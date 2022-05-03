include_set Abstract::CommonFilters

format :html do
  Abstract::CommonFilters::HtmlFormat.define_filter_types verification: :select,
                                                          updater: :select,
                                                          value: :text,
                                                          calculated: :select,
                                                          status: :select,
                                                          updated: :select,
                                                          outliers: :select,
                                                          source: :autocomplete

  def filter_status_default
    "exists"
  end

  def filter_outliers_default
    "only"
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

  def filter_calculated_options
    { "Yes" => :calculated, "No" => :not_calculated }
  end

  def filter_status_label
    "Status"
  end

  def filter_value_label
    "Value"
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
