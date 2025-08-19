include_set Abstract::StewardPermissions
include_set Abstract::PublishableField

assign_type :list

event :update_stewarded_answers, :finalize, changed: :content do
  metric_card.answers.each(&:update_verification)
end
