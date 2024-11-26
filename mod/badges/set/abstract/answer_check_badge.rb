include_set Abstract::AnswerBadge

format :html do
  def valued_action
    "double-checking"
  end
end

def badge_action
  :check
end
