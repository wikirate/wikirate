include_set Abstract::MetricChild, generation: 1

delegate :researchable?, to: :metric_card

event :verify_no_current_answers_inapplicable, :validate,
      on: :save, changed: :content, when: :researchable? do
  return unless content.present? && inapplicable_answers.any?

  errors.add :content, "Invalid #{name.right} applicability restriction." \
    "This change would disallow existing researched answers."
end

def researched_answers
  Answer.where "metric_id = #{metric_id} AND answer_id IS NOT NULL"
end
