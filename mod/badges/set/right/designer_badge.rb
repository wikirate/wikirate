include_set Abstract::AffinityBadge

format :html do
  view :description do
    "Awarded for adding #{threshold} answers for metrics designed by #{affinity}"
  end
end

def affinity_type
  :designer
end
