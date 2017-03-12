include_set Abstract::AwardBadges, hierarchy_type: :wikirate_company

event :award_company_logo_badges, before: :refresh_updated_answers,
      on: :save do
  award_badge_if_earned :logo
end

