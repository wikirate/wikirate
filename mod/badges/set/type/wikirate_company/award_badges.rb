include_set Abstract::AwardBadges, squad_type: :wikirate_company

event :award_company_create_badges, :finalize,
      on: :create do
  award_badge_if_earned :create
end
