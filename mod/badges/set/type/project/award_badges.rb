include_set Abstract::AwardBadges, squad_type: :project

event :award_project_create_badges, :finalize,
      on: :create do
  award_badge_if_earned :create
end
