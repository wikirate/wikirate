format :html do
  view :formula_core do
    table formula_core_table_rows, header: %w[Variable Metric Options]
  end

  def formula_input
    custom_variable_input :formula_input
  end

  def formula_filtered_item_view
    :formula_variable_row
  end

  def formula_filtered_item_wrap
    :none
  end

  def options_schemes
    {
      "All Researched (default)": :all_researched,
      "Any Researched": :any_researched,
      "Custom": :custom
    }
  end

  private

  view :options_editor, template: :haml #, wrap: :modal

  def formula_core_table_rows
    card.hash_list.clone.map do |hash|
      [hash.delete(:name),
       nest(hash.delete(:metric), view: :thumbnail),
       formula_options_cell(hash)]
    end
  end

  def formula_options_cell options
    haml :options_cell, options: options
  end
end

format :json do
  view :input_lists do
    metric_card.calculator.input_values.with_object([]) do |(vals, _comp, _year), array|
      array << vals
    end
  end
end
