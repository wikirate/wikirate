#! no set module

# all badges related to metrics
class BadgeSquad
  extend Abstract::BadgeSquad

  add_badge_line :create,
                 metric_creator: 1,
                 metric_tonnes: 4,
                 research_agenda_setter: 16,
                 &create_type_count(MetricID)

  add_badge_line :vote,
                 metric_voter: 1,
                 metric_critic: 5,
                 metric_connoisseur: 25,
                 &vote_count(MetricID)
end
