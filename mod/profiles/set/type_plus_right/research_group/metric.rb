def virtual?
  new?
end

def cql_content
  { type_id: Card::MetricID, left: "_left" }
end
