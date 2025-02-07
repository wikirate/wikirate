# handles company fields (eg headquarters) that are duplicated as metric answer
#
# includer must define #metric code

event :update_company_field_answer_lookup, :finalize do
  metric_card&.calculate_answers company_id: answer_company_id, year: answer_year
end

def metric_code
  raise Card::Error::ServerError, "must define #metric_code"
end

def metric_card
  return if Array.wrap(metric_code).find { |mc| !Codename.exist? mc }
  # conditional needed for seeding.
  metric_code.card
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
