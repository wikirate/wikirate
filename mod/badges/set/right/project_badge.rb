include_set Abstract::RecordCreateAffinityBadge

format :html do
  view :description do
    "Awarded for adding #{threshold} records for  #{affinity} metrics / companies"
  end
end

def affinity_type
  :project
end
