include_set Abstract::AnswerBadge

format :html do
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
