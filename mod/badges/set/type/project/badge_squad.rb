#! no set module

class BadgeSquad
  extend Abstract::BadgeSquad

  add_badge_line :create,
                 project_launcher: 1,
                 &create_type_count(ProjectID)

  add_badge_line :discuss,
                 project_q_a: [1, :silver],
                 &type_plus_right_edited_count(ProjectID, DiscussionID)
end
