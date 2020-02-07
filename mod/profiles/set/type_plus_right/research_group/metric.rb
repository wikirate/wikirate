def virtual?
  new?
end

def wql_content
  { type_id: Card::MetricID, left: "_left" }
end
