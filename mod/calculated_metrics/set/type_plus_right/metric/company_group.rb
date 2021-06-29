include_set Abstract::MetricChild, generation: 1

event :enforce_company_applicability_to_calculations, :after_integrate, skip: :allowed do
  return if metric_card.action.in?(%i[create delete]) || !metric_card.calculated?
  # return unless wrong_companied_answers?

  metric_card.deep_answer_update
end

# this finds false positives but not false negatives
def wrong_companied_answers?
  metric_card.answers.where("company_id not in (#{company_ids.join ', '})").any?
end

def company_ids
  groups = item_cards
  return [] unless groups.present?

  groups.map { |g| g.wikirate_company_card&.item_ids }.flatten.compact
end
