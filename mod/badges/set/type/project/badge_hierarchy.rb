#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  hierarchy(
    create: {
      project_launcher: 1
    },
    discuss: {
      projected_voice: [1, :silver]
    }
  )
end
