include_set Abstract::AwardBadges, hierarchy_type: :metric_value

event :award_answer_update_badges, before: :refresh_updated_answers,
      on: :update do
  award_badge_if_earned :update
end
