include_set Abstract::AnswerUpdateBadge

format :html do
  def valued_action
    "updating"
  end

  def valued_object
    "answer value"
  end
end
