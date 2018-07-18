include_set Abstract::AwardBadges, squad_type: :metric

event :award_metric_create_badges, :finalize,
      on: :create do
  award_badge_if_earned :create
end
