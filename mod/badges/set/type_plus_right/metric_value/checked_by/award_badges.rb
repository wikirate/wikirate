include_set Abstract::AwardBadges, hierarchy_type: :metric_value

event :award_answer_check_badges, before: :refresh_updated_answers,
      on: :save do
  award_badge_if_earned :check
end
