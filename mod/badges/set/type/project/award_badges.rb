include_set Abstract::AwardBadges, hierarchy_type: :project

event :award_project_create_badges, before: :refresh_updated_answers,
      on: :create do
  award_badge_if_earned :create
end

