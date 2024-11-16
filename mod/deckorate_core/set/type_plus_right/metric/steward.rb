include_set Abstract::DesignerPermissions
include_set Abstract::PublishableField

assign_type :list

def metric_card
  left
end

event :update_stewarded_records, :finalize, changed: :content do
  metric_card.records.each(&:update_verification)
end
