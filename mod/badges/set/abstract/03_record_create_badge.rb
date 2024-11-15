include_set Abstract::RecordBadge

format :html do
  view :level do
    super() # + "<div class='badge-affinity-connection'>&nbsp;</div>".html_safe
  end

  def valued_action
    "adding"
  end
end

def badge_action
  :create
end

def affinity_type
  :general
end
