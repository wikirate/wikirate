include_set Abstract::MetricChild, generation: 3
include_set Abstract::PublishableField

event :update_related_verifications, :after_integrate, skip: :allowed do
  answer_card.update_related_verifications
end
