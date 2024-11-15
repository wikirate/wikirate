include_set Abstract::RecordCreateAffinityBadge

format :html do
  view :description do
    "Awarded for adding #{threshold} records for metrics designed by #{affinity}"
  end
end

def affinity_type
  :designer
end
