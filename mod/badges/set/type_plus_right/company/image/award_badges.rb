include_set Abstract::AwardBadges, squad_type: :company

event :award_company_logo_badges, :finalize, on: :save do
  award_badge_if_earned :logo
end
