# handles company fields (eg headquarters) that are duplicated as metric answers
#
# includer must define #metric code

event :update_company_field_answer_lookup, :finalize do
  update_direct_answer_lookup
  update_depender_answers
end

def metric_code
  raise Card::Error::ServerError, "must define #metric_code"
end

def metric_card
  Card[metric_code]
end

def update_direct_answer_lookup
  metric_card.calculate_answers company_id: answer_company_id, year: answer_year
end

def update_depender_answers
  metric_card.update_depender_values_for! answer_company_id
end

def answer_company_id
  left_id
end

def answer_value
  first_name
end

def answer_year
  ::Calculate::CompanyField::YEAR
end
