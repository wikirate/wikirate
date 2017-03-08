include_set Abstract::AwardBadges

def badge_hierarchy
  Type::MetricValue::BadgeHierarchy
end

event :award_answer_check_badges, before: :refresh_updated_answers,
      on: :save do
  award_badge_if_earned :check
end

def check_count
  Card.search left: { type_id: MetricValueID },
              right_id: CheckedByID,
              refer_to: { id: Auth.current_id },
              return: :count
end
