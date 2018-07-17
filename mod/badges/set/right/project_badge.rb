include_set Abstract::AnswerCreateAffinityBadge

format :html do
  view :description do
    "Awarded for adding #{threshold} answers for  #{affinity} metrics / companies"
  end
end

def affinity_type
  :project
end
