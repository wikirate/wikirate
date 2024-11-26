include_set Abstract::DesignerPermissions
include_set Abstract::PublishableField

assign_type :list

def metric_card
  left
end

event :update_stewarded_answers, :finalize, changed: :content do
  metric_card.answer.each(&:update_verification)
end
