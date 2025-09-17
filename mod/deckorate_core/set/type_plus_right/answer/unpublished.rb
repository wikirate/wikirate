include_set Abstract::MetricChild, generation: 3
include_set Abstract::LookupField
include_set Abstract::StewardPermissions
include_set Abstract::PublishableField

event :update_calculated_unpublished, :finalize, changed: :content do
  # if creating or deleting answer, lookup values will be refreshed elsewhere
  return if lookup_card.action.in? %i[create delete]

  lookup_card.each_depender_answer { |answer| answer.refresh :unpublished }
end

def stewarded_card
  metric_card
end
