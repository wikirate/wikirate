def calculator_class
  Formula::HardCoded
end

# can be overridden, but by default only validates that input is not unknown
def validate_input input, _index
  !Array.wrap(input).flatten.any? { |inp| Answer.unknown? inp }
end


format :html do
  view :editor do
    "Formula is hard-coded and cannot be edited"
  end

  view :variable_metrics do
    listing card.item_names, view: :formula_thumbnail
  end
end
