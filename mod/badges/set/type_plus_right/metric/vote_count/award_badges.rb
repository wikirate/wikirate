include_set Abstract::AwardBadges, squad_type: :metric

event :award_metric_vote_badges, :finalize,
      on: :save, changed: :content, when: ->(_c) { Card::Auth.signed_in? } do
  award_badge_if_earned :vote
end
