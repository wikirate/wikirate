include_set Abstract::Hybrid
include_set Abstract::Calculation

def calculator_class
  Calculate::JavaScript
end

def formula_field
  :formula
end

format :json do
  view :input_lists, unknown: true do
    array = []
    card.calculator.input_values do |vals, _comp, _year|
      array << vals
    end
    { total: array.size, sample: array[0, 1000] }
  end
end
