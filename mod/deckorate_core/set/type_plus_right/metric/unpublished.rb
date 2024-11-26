include_set Abstract::MetricChild, generation: 1
include_set Abstract::LookupField
include_set Abstract::DesignerPermissions
include_set Abstract::PublishableField

delegate :unpublished?, :published?, :calculated?, to: :metric_card

assign_type :toggle

event :toggle_answer_publication, :finalize, changed: :content do
  if content == "1"
    unpublish_all_answers
  else
    publish_unflagged_answers
  end
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

def answers
  ::Answer.where metric_id: left_id
end

def unpublish_all_answers
  answers.update_all unpublished: true
end

def publish_unflagged_answers
  answers.where(
    "NOT EXISTS (
      SELECT * from cards
      WHERE left_id = answers.answer_id
      AND right_id = #{:unpublished.card_id}
      AND db_content= '1'
    )"
  ).update_all unpublished: false
end
