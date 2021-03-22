# handles company fields (eg headquarters) that are duplicated as metric answers
#
# must define #metric code

event :update_company_field_answer_lookup, :integrate, on: :save do
  Card[metric_code].update_or_add_answer(
    answer_company_id,
    answer_year,
    answer_value
  )
end


def answer_company_id
  left_id
end

def answer_value
  first_name
end

def answer_year
  ::Formula::CompanyField::YEAR
end
