def calculator_class
  Calculate::HardCoded
end

def calculator _parser_method=nil
  calculator_class.new self
end

format :html do
  def nest_formula
    "Formula is hard-coded"
  end

  # view :variable_metrics do
  #   listing_list card.item_names, view: :formula_thumbnail
  # end
end
