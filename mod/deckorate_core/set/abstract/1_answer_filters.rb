include_set Abstract::CommonFilters
include_set Abstract::BookmarkFiltering

format :html do
  Abstract::CommonFilters::HtmlFormat.define_filter_types verification: :check,
                                                          updater: :radio,
                                                          value: :text,
                                                          calculated: :radio,
                                                          status: :radio,
                                                          updated: :radio,
                                                          # outliers: :radio,
                                                          source: :multiselect

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

  def filter_verification_closer_value value
    ::Answer.verification_title value
  end

  def filter_updater_options
    o = {}
    o["by Me"] = "current_user" if Card::Auth.signed_in?
    o["by Wikirate Team"] = "wikirate_team" if Self::WikirateTeam.member?
    o
  end

  def filter_calculated_options
    { "Yes" => :calculated, "No" => :not_calculated }
  end

  def filter_source_options
    :remote_type
  end

  def filter_status_label
    "Status"
  end

  def filter_route_type
    "check"
  end

  def filter_route_options
    ::Answer::ROUTES.values.each_with_object({}).with_index do |(v, h), i|
      h[v] = i.to_s
    end
  end

  def filter_route_closer_value value
    ::Answer::ROUTES.values[value.to_i]
  end

  def filter_value_label
    "Value"
  end

  # the "closer" is the ui badge that closes a filter
  def filter_value_closer_value value
    case value
    when Array
      value.join ", "
    when Hash
      hash_value_closer_value value
    else
      value
    end
  end

  def filter_updated_closer_value value
    filter_value_closer_value value
  end

  private

  def hash_value_closer_value value
    [
      ("> #{value[:from]}" if value[:from]),
      ("< #{value[:to]}" if value[:to])
    ].compact.join ", "
  end

  def standard_verification_options
    ::Answer::VERIFICATION_LEVELS.map.with_object({}) do |level, opts|
      opts[level[:title]] = level[:name]
    end
  end

  def verified_by_me_option opts
    opts["Verified by Me"] = "current_user" if Card::Auth.signed_in?
  end

  def verified_by_wikirate_team opts
    opts["Verified by Wikirate Team"] = "wikirate_team" if Self::WikirateTeam.member?
  end
end
