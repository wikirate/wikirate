include_set Abstract::MetricChild, generation: 1

delegate :researchable?, :calculated?, to: :metric_card

event :verify_no_current_answers_inapplicable, :validate,
      on: :save, changed: :content, when: :researchable? do

  return if errors[:content].any?
  return unless content.present? && metric_id && inapplicable_answers.any?

  errors.add :content, "Invalid #{name.right} applicability restriction." \
    "This change would disallow existing researched answers."
end

event :enforce_applicability_to_calculations, :integrate_with_delay,
      skip: :allowed, priority: 5, when: :calculated? do
  metric_card.calculate_answers unless metric_card.action.in? %i[create delete]
end

def researched_answers
  ::Answer.where "metric_id = #{metric_id} AND answer_id IS NOT NULL"
end
