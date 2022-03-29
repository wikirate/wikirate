def count
  ::Answer.joins(:metric).where(metric: { metric_type_id: left_id }).count
end

format do
  delegate :count, to: :card
end
