include_set Set::Abstract::Calculation

delegate :weight_hash, to: :variables_card

# <OVERRIDES>
def rating?
  true
end

def ten_scale?
  true
end

def calculator_class
  ::Calculate::WikiRating
end

def variables_input_type
  :rating
end
# </OVERRIDES>

event :create_formula, :initialize, on: :create do
  sf = subfield :formula
  sf.content = "{}" unless sf.content.present?
end

format do
  def formula_field
    :variables
  end

  def value_legend
    "0-10"
  end
end

