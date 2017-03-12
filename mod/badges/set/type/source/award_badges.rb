include_set Abstract::AwardBadges, hierarchy_type: :source

event :award_source_create_badges, before: :refresh_updated_answers,
      on: :create do
  award_badge_if_earned :create
end
