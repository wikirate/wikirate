def count
  RecordQuery.new(metric_type: left_id).count
end

format do
  delegate :count, to: :card
end
