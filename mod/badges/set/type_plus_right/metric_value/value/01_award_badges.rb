include_set Abstract::AwardBadges, squad_type: :metric_value

event :award_answer_update_badges, :finalize,
      on: :update do
  award_badge_if_earned :update
end
