include_set Abstract::AwardBadges, squad_type: :metric_answer

event :award_metric_answer_discussion_badges, :finalize,
      on: :save do
  award_badge_if_earned :discuss
end
