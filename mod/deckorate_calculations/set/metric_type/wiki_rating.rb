include_set Set::Abstract::Calculation

# <OVERRIDES>
def rating?
  true
end

def ten_scale?
  true
end

def formula_editor
  :rating_editor
end

def formula_core
  :rating_core
end

def calculator_class
  ::Calculate::WikiRating
end
# </OVERRIDES>

event :create_formula, :initialize, on: :create do
  ensure_subfield :formula, content: "{}"
end

format do
  def value_legend
    "0-10"
  end
end
