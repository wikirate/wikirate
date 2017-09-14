include_set Abstract::AwardBadges, squad_type: :metric_value

event :award_metric_value_discussion_badges, :finalize,
      on: :save do
  award_badge_if_earned :discuss
end
