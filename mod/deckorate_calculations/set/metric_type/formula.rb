include_set Abstract::Hybrid
include_set Abstract::Calculation

SAMPLE_SIZE = 100

def calculator_class
  Calculate::JavaScript
end

def formula_field
  :formula
end

format :json do
  view :input_lists, unknown: true do
    array = card.calculator.raw_input_values
    unknown = array.select { |list| list.first == :unknown }
    sample = array.reject { |list| list.first == :unknown }
    { total: array.size, sample: sample[0, SAMPLE_SIZE], unknown: unknown.count }
  end
end
