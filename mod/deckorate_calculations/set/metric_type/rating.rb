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
  ::Calculate::Rating
end

def calculation_types
  %i[rating formula descendant]
end

format :html do
  def edit_properties
    { benchmark: "Benchmark" }.merge super
  end

  def table_properties
    super.merge benchmark: "Benchmark"
  end

  def benchmark_property title
    labeled_field :benchmark, nil, title: title
  end
end
