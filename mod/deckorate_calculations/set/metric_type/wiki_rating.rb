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
# </OVERRIDES>

format do
  def value_legend
    "0-10"
  end
end

