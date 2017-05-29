include_set Abstract::AwardBadges, squad_type: :metric_value

event :award_answer_check_badges, :finalize,
      on: :save do
  award_badge_if_earned :check
end
