#! no set module

# all badges related to projects
class BadgeSquad
  extend Abstract::BadgeSquad

  add_badge_line :create,
                 project_launcher: [1, :silver],
                 &create_type_count(ProjectID)

  add_badge_line :discuss,
                 project_q_a: 1,
                 &type_plus_right_edited_count(ProjectID, DiscussionID)
end
