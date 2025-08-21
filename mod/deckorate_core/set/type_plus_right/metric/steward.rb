def metric_card
  left
end

event :update_stewarded_answers, :finalize, changed: :content do
  metric_card.answers.each(&:update_verification)
end
