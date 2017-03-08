include_set Abstract::AwardBadges

def badge_hierarchy
  Type::Project::BadgeHierarchy
end

event :award_project_discussion_badges, before: :refresh_updated_answers,
      on: :save do
  award_badge_if_earned :discuss
end

def discuss_count
  Card.search left: { type_id: ProjectID },
              right_id: DiscussionID,
              edited_by: Auth.current_id,
              return: :count
end

