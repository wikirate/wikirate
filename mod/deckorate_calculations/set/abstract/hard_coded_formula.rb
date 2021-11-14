def calculator_class
  Calculate::HardCoded
end

format :html do
  view :input do
    "Formula is hard-coded and cannot be edited"
  end

  view :variable_metrics do
    listing card.item_names, view: :formula_thumbnail
  end
end
