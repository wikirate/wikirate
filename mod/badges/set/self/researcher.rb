
format :html do
  view :description do
    "Awarded for adding #{treshold} answers."
  end
end

def affinity_type
  :general
end

def threshold
  badge_class.treshold :create, affinity_type, badge_key
end

def badge_class
  Type::MetricValue::Badges
end