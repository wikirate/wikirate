include_set Abstract::RecordBadge

format :html do
  def valued_action
    "contribution"
  end

  def valued_object
    "discussion"
  end
end

def badge_action
  :discuss
end
