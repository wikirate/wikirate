include_set Abstract::AwardBadges, hierarchy_type: :metric

event :award_metric_create_badges, before: :refresh_updated_answers,
      on: :create do
  award_badge_if_earned :create
end
