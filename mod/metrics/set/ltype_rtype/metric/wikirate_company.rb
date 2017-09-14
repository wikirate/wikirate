include_set Abstract::WikirateTable # deprecated, but not clear if it is still used
include_set Abstract::MetricChild, generation: 1
include_set Abstract::Table

def latest_value_year
  Answer.latest_year metric_card.id, company_card.id
end

def latest_value_card
  Answer.latest_answer_card metric_card.id, company_card.id
end

def virtual?
  true
end
