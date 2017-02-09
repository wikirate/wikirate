include_set Abstract::WikirateTable # deprecated, but not clear if it is still used
include_set Abstract::MetricChild, generation: 1
include_set Abstract::Table

def latest_value_year
  cached_count
end

def latest_value_card
  return if !(lvy = latest_value_year) || lvy == 0
  Card.fetch cardname, lvy.to_s
end

def virtual?
  true
end
