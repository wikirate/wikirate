include_set Abstract::RecordBadge

format :html do
  def valued_action
    "editing"
  end
end

def badge_action
  :update
end
