include Set::Abstract::Calculation

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
  ::Formula::WikiRating
end
# </OVERRIDES>

event :create_formula, :initialize, on: :create do
  ensure_subfield :formula, content: "{}"
end

format :html do
  def value_legend _html=true
    "0-10"
  end
end
