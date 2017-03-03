include_set Abstract::AffinityBadge

format :html do
  view :description do
    "Awarded for adding #{threshold} answers about #{affinity}"
  end
end

def affinity_type
  :company
end
