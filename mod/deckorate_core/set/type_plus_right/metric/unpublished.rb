include_set Abstract::MetricChild, generation: 1
include_set Abstract::LookupField
include_set Abstract::StewardPermissions
include_set Abstract::PublishableField

delegate :unpublished?, :published?, :calculated?, to: :metric_card

assign_type :toggle

event :toggle_answer_publication, :finalize, changed: :content do
  method = content == "1" ? :unpublish_all_answers : :publish_unflagged_answers
  metrics.each { |m| m.send method }
end

# unpublishing a metric means unpublishing all calculations that depend on that metric
event :unpublish_calculations, :finalize, changed: :content, when: :unpublished? do
  metric_card.direct_depender_metrics.each do |metric|
    metric.unpublished_card.update content: 1
  end
end

# publishing a metric means publishing all inputs a metric depends on
event :publish_inputs, :finalize, changed: :content, when: :publish_inputs? do
  metric_card.direct_dependee_metrics.each do |metric|
    metric.unpublished_card.update content: 0
  end
end

def publish_inputs?
  published? && calculated? && !metric_card.trash
end

def metrics
  [metric_card, metric_card.try(:inverse_card)].compact
end
