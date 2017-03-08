include_set Abstract::AwardBadges

event :award_project_create_badges, before: :refresh_updated_answers,
      on: :create do
  award_badge_if_earned :create
end

def badge_hierarchy
  Type::Project::BadgeHierarchy
end

def create_count
  Card.search type_id: ProjectID,
              created_by: Auth.current_id,
              return: :count
end
