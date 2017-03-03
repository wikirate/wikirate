format :html do
  delegate :badge_level, to: :card

  view :level do
    glyphicon :certificate, badge_level
  end

  view :badge do
    card.name
  end
end

def threshold
  badge_class.treshold :create, affinity_type, badge_key
end

def badge_class
  Type::MetricValue::Badges
end

def badge_level
  badge_class.badge_level[badge_key]
end

def badge_key
  key
end
