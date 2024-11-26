include_set Abstract::MetricChild, generation: 3
include_set Abstract::PublishableField

# without this, lookup table does not update correctly
event :remove_checkers, :validate, on: :delete do
  self.content = ""
end

event :update_related_verifications, :after_integrate, skip: :allowed do
  answer_card.update_related_verifications
end
