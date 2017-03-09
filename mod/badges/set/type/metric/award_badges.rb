include_set Abstract::AwardBadges

event :award_metric_create_badges, before: :refresh_updated_answers,
      on: :create do
  award_badge_if_earned :create
end

def badge_hierarchy
  Type::Metric::BadgeHierarchy
end

def create_count user_id=nil
  Card.search type_id: MetricID,
              created_by: user_id || Auth.current_id,
              return: :count
end

