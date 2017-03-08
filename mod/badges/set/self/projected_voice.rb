include_set Abstract::Badge

format :html do
  def valued_action
    "discussing"
  end

  def valued_object
    "project"
  end
end

def badge_action
  :discuss
end

def badge_type
  :project
end
