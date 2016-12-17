def virtual?
  true
end

def raw_ruby_query
  { type_id: MetricID, left: "_left" }
end
