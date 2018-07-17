include_set Abstract::AwardBadges, squad_type: :metric_answer

event :award_answer_check_badges, :finalize,
      on: :save, changed: :content do
  award_badge_if_earned :check
end
