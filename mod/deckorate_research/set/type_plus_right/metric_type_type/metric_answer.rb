def count
  AnswerQuery.new(metric_type: left_id).count
end

format do
  delegate :count, to: :card
end
