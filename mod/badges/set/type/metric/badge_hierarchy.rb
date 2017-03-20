#! no set module

class BadgeHierarchy
  extend Abstract::BadgeHierarchy

  add_badge_set :create,
                metric_creator: 1,
                metric_tonnes: 4,
                research_agenda_setter: 16,
                &create_type_count(MetricID)


  add_badge_set :vote,
                metric_voter: 1,
                metric_critic: 5,
                metric_connoisseur: 25,
                &vote_count(MetricID)
end
