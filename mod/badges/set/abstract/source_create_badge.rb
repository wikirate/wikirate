include_set Abstract::AnswerBadge

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

