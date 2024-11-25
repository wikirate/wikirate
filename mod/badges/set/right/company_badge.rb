include_set Abstract::AnswerCreateAffinityBadge

format :html do
  view :description do
    "Awarded for adding #{threshold} answer about #{affinity}"
  end
end

def affinity_type
  :company
end
