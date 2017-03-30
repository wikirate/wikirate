include_set Abstract::AwardBadges, hierarchy_type: :source

event :award_source_create_badges, :finalize,
      on: :create do
  award_badge_if_earned :create
end
