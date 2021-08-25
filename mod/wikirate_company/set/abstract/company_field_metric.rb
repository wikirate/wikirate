include_set Abstract::Calculation

def calculator_class
  Calculate::CompanyField
end

def calculator _parser_method=nil
  calculator_class.new company_field_code, self
end

def company_field_code
  raise Card::Error::ServerError, "#company_field_code required"
end

format :html do
  def nest_formula
    "<em>Pulled from company field: #{card.company_field_code.cardname}</em>"
  end
end
