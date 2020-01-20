include_set Abstract::MetricBadge

format :html do
  def valued_action
    "bookmarking"
  end
end

def badge_action
  :bookmark
end
