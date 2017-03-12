#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  add_badge_set :create,
                project_launcher: 1,
                &create_type_count(ProjectID)

  add_badge_set :discuss,
                projected_voice: [1, :silver],
                &type_plus_right_edited_count(ProjectID, DiscussionID)
end
