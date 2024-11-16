include_set Abstract::RecordUpdateBadge

format :html do
  def valued_action
    "updating"
  end

  def valued_object
    "record value"
  end
end
