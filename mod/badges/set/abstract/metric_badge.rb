include_set Abstract::Badge

format :html do
  def valued_action
    "adding"
  end

  def valued_object
    "metric"
  end
end

def badge_action
  :create
end

def badge_type
  :metric
end
