format :html do
  delegate :affinity, :affinity_card, :badge_level, to: :card

  view :level do
    glyphicon :certificate, badge_level
  end

  view :badge do
    nest affinity_card, view: :thumbnail
  end
end

def badge_class
  Type::MetricValue::Badges
end

def badge_level
  badge_class.badge_level[badge_key]
end

def affinity
  cardname.parts[0]
end

def affinity_card
  card[0]
end

def badge_key
  cardname.part_keys[1]
end
