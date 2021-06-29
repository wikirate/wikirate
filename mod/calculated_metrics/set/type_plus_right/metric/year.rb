include_set Abstract::MetricChild, generation: 1

event :enforce_year_applicability_to_calculations, :after_integrate, skip: :allowed do
  return if metric_card.action.in?(%i[create delete]) || !metric_card.calculated?
  return unless wrong_yeared_answers?

  metric_card.deep_answer_update
end

def wrong_yeared_answers?
  metric_card.answers.where("year not in (#{item_names.join ', '})").any?
end
