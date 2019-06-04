def virtual?
  new?
end

def wql_from_content
  { type_id: MetricID, left: "_left" }
end
