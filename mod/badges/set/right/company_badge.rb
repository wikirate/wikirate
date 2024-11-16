include_set Abstract::RecordCreateAffinityBadge

format :html do
  view :description do
    "Awarded for adding #{threshold} records about #{affinity}"
  end
end

def affinity_type
  :company
end
