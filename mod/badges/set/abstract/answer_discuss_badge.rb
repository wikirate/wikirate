include_set Abstract::AnswerBadge

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
