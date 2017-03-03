include_set Abstract::BadgeType

format :html do
  view :description do
    "Awarded for adding #{} about #{affinity}"
  end
end

def affinity_type
  :company
end
