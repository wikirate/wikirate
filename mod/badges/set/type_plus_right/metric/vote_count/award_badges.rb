include_set Abstract::AwardBadges, hierarchy_type: :metric

event :award_metric_vote_badges, before: :refresh_updated_answers,
      on: :save, when: -> (_c) { Card::Auth.signed_in? } do
  award_badge_if_earned :vote
end
