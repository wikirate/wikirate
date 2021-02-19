include_set Abstract::DesignerPermissions

def metric_card
  left
end

event :update_stewarded_answers, :integrate_with_delay, changed: :content do
  metric_card.answers.each(&:update_verification)
end
