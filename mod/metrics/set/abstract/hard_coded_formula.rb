def hard_coded?
  true
end

def clean_formula
  :hard_coded_formula_stub
end

def get_value input
  binding.pry
end

def normalize_value value
  binding.pry
end

def validate_input input, _index
  !Array.wrap(input).any? { |inp| Answer.unknown? inp }
end

def calculator_class
  Formula::HardCoded
end

format :html do
  view :editor do
    "Formula is hard-coded and cannot be edited"
  end
end
