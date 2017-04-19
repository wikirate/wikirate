include_set Abstract::Badge

format :html do
  def valued_action
    "creating"
  end

  def valued_object
    "project"
  end
end

def badge_action
  :create
end

def badge_type
  :project
end
