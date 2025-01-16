include_set Abstract::Applicability

def ok_item_types
  :company_group
end

def inapplicable_answers
  researched_answers.where.not company_id: company_ids
end

def company_ids
  groups = item_cards
  return [] unless groups.present?

  groups.map { |g| g.company_card&.item_ids }.flatten.compact.uniq
end
