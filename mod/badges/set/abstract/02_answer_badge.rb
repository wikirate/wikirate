include_set Abstract::BadgeShowroom

format :html do
  def valued_object
    "answer"
  end
end

def badge_class
  Type::MetricValue::BadgeHierarchy
end
