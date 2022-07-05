def virtual?
  new?
end

def count
  ::Metric.where(metric_type_id: left_id).count
end

def cql_content
  { right_plus: [:metric_type, { refer_to: left_id }] }
end

format do
  delegate :count, to: :card
end
