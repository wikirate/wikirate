def virtual?
  new?
end

def wql_content
  { type_id: MetricID, left: "_left" }
end
