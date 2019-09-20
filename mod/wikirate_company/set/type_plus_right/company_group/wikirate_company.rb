include_set Right::BrowseCompanyFilter

# cache # of companies in this group
include_set Abstract::AnswerTableCachedCount, target_type: :company

delegate :specification_card, to: :left

def constraints
  specification_card.constraints
end

# TODO: this currently only works with one constraint. Should work for more
def search_anchor
  c = constraints.first
  answer_query = AnswerQuery.new metric_id: c.metric.id, year: c.year, value: c.value
  { where: answer_query.answer_conditions }
end

def skip_search?
  constraints.empty?
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
  company_groups_for_metric(metric_card.id).map &:wikirate_company_card
end

class << self
  def company_groups_for_metric metric_id
    Card.search type: :company_group,
                right_plus: [:specification, { refer_to: metric_id }]
  end
end