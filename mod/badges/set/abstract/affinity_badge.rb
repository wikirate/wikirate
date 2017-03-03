format :html do
  delegate :affinity, :affinity_card, to: :card

  view :badge do
    nest affinity_card, view: :thumbnail
  end
end

def threshold
  badge_class.treshold :create, affinity_type, badge_key
end

def badge_class
  Type::MetricValue::Badges
end

def affinity
  cardname.parts[0]
end

def affinity_card
  card[0]
end
