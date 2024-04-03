def formula_metric_and_detail
  card.hash_list.clone.map do |hash|
    metric = hash.delete :metric
    [metric, hash]
  end
end

format :html do
  def formula_algorithm
    nest metric_card.formula_card, view: :content
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

  view :options_editor, template: :haml, unknown: true #, wrap: :modal

  def formula_options_cell options
    haml :options_cell, options: options
  end
end
