#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  hierarchy(
    create: {
      metric_creator: 1,
      i_so_metric: 4,
      helio_metric: 16
    },
    vote: {
      metric_voter: 1,
      metric_critic: 5,
      metric_voting_machine: 25
    }
  )
end
