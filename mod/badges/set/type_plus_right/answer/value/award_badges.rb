include_set Abstract::AwardBadges, squad_type: :answer

event :award_answer_update_badges, :finalize, on: :update, changed: :content do
  award_badge_if_earned :update
end
