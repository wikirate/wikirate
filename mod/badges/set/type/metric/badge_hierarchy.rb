#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  add_badge_set :create,
                metric_creator: 1,
                i_so_metric: 4,
                helio_metric: 16,
                &create_type_count(MetricID)


  add_badge_set :vote,
                metric_voter: 1,
                metric_critic: 5,
                metric_voting_machine: 25,
                &vote_count(MetricID)
end
