# handles company fields (eg headquarters) that are duplicated as metric records
#
# includer must define #metric code

event :update_company_field_record_lookup, :finalize do
  metric_card&.calculate_records company_id: record_company_id, year: record_year
end

def metric_code
  raise Card::Error::ServerError, "must define #metric_code"
end

def metric_card
  # conditional needed for seeding.
  Card[metric_code] if Codename.exist? metric_code
end

def record_company_id
  left_id
end

def record_value
  first_name
end

def record_year
  ::Calculate::CompanyField::YEAR
end
