# the +:metric_variables card on Formula metrics supports a two phase process:
#   1. find variable metrics
#   2. add them to the formula (using a short name if desired)

# @param variable [String] M0, M1, etc
# @return [Card::Name]
def input_metric_name variable
  index = variable_index variable
  input_metric_name_by_index index if index
end

# @return [Card::Name]
def input_metric_name_by_index index
  item_cards.fetch(index, nil).name
end

format :html do
  view :edit_in_formula, unknown: true, cache: :never do
    as_formula_subcard { variables_table_and_button }
  end

  # content is submitted along with formula so that variables cane interpreted
  def as_formula_subcard
    @explicit_form_prefix = "card[subcards][#{card.name}]"
    reset_form
    output [render_hidden_content_field, yield]
  end

  def add_formula_variable_button
    add_variable_button "_add-formula-variable", slot_selector(:edit_in_formula)
  end

  def variables_table_and_button
    variable_editor { output [variables_table, add_formula_variable_button] }
  end

  def variables_table
    items = card.item_names context: :raw
    table items.map.with_index { |item, index| variable_row item, index },
          header: ["Metric", "Variable", "Example value"]
  end

  def variable_row item_name, index
    item_card = Card[item_name]
    [nest(item_card, view: :thumbnail), "M#{index}", example_value(item_card).html_safe]
  end

  def example_value variable_card
    return "" unless (value = variable_card.try(:random_value_card))
    nest(value, view: :year_and_value).html_safe # html_safe necessary?
  end
end
