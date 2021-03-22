include_set Abstract::Calculation

def calculator_class
  Formula::CompanyField
end

def calculator _parser_method=nil
  calculator_class.new company_field_code, &method(:normalize_value)
end
