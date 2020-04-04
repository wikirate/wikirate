#! no set module

# all badges related to metrics
class BadgeSquad
  if defined? Card::MetricID
    extend Abstract::BadgeSquad
    add_badge_line :create,
                   metric_creator: 1,
                   metric_tonnes: 4,
                   research_agenda_setter: 16,
                   &create_type_count(Card::MetricID)

    add_badge_line :bookmark,
                   metric_bookmarker: 1,
                   metric_critic: 5,
                   metric_connoisseur: 25,
                   &bookmark_count(Card::MetricID)
  end
end
