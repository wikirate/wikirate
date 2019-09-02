include_set Abstract::AwardBadges, squad_type: :source

event :award_source_create_badges, :finalize, on: :create do
  award_badge_if_earned :create
end
