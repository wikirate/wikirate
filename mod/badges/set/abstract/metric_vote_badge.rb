include_set Abstract::MetricBadge

format :html do
  def valued_action
    "voting"
  end
end

def badge_action
  :vote
end
