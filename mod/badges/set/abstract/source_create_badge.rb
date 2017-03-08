include_set Abstract::Badge

format :html do
  def valued_action
    "adding"
  end

  def valued_object
    "source"
  end
end

def badge_action
  :create
end

def badge_type
  :source
end
