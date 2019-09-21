include_set Right::BrowseCompanyFilter
# currently needs to come before cached count handling, because
# both override #wql_content

# cache # of companies in this group
include_set Abstract::AnswerTableCachedCount, target_type: :company

delegate :specification_card, to: :left

def constraints
  specification_card.constraints
end

def target_ids
  return [] if constraints.empty?
  relation.pluck :id
end

def recount
  return 0 if constraints.empty?
  relation.count
end

def relation
  exist_clauses = constraint_clauses.map { |cc| "exists (#{cc})" }
  Card.where exist_clauses.join(" and ")
end

def constraint_clauses
  constraints.map do |constraint|
    "select company_name from answers " \
    "where #{constraint_conditions constraint} " \
    "and answers.company_id = cards.id"
  end
end

def constraint_conditions constraint
  answer_query = AnswerQuery.new metric_id: constraint.metric.id,
                                 year: constraint.year,
                                 value: constraint.value
  answer_query.answer_conditions
end

# when specification is edited
recount_trigger :type_plus_right, :company_group, :specification do |changed_card|
  changed_card.left.wikirate_company_card
end

# FIXME: this won't work if answer is calculated
# (that applies to several similar triggers)
# when metric value is edited
recount_trigger :type, :metric_answer do |changed_card|
  next unless (metric_card = changed_card.metric_card)
  company_groups_for_metric(metric_card.id).map(&:wikirate_company_card)
end

class << self
  def company_groups_for_metric metric_id
    Card.search type: :company_group,
                right_plus: [:specification, { refer_to: metric_id }]
  end
end
