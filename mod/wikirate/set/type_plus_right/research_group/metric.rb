def virtual?
  true
end

def raw_ruby_query _override
  { type_id: MetricID, left: "_left" }
end
