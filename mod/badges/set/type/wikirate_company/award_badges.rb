include_set Abstract::AwardBadges, hierarchy_type: :wikirate_company

event :award_company_create_badges, before: :refresh_updated_answers,
      on: :create do
  award_badge_if_earned :create
end
