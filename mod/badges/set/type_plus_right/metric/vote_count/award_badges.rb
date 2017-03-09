include_set Abstract::AwardBadges

def badge_hierarchy
  Type::Metric::BadgeHierarchy
end

event :award_metric_vote_badges, before: :refresh_updated_answers,
      on: :save do
  award_badge_if_earned :vote
end

def vote_count user_id=nil
  user = user_id ? Card[user_id] : Auth.current
  vote_card_ids =
    [user.upvotes_card.id, user.downvotes_card.id].compact
  return 0 unless vote_card_ids.present?

  Card.search type_id: Card::MetricID,
              referred_to_by: { id: ["in"] + vote_card_ids },
              return: :count
end
