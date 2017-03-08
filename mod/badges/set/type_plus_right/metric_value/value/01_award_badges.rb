include_set Abstract::AwardBadges

def badge_hierarchy
  Type::MetricValue::BadgeHierarchy
end

event :award_answer_update_badges, before: :refresh_updated_answers,
      on: :update do
  award_badge_if_earned :update
end

def update_count
  Card.search left: { type_id: MetricValueID },
              right_id: ValueID,
              updated_by: Auth.current_id,
              return: :count
end
