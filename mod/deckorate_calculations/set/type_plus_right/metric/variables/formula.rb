format :html do
  view :formula_core, template: :haml

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

  def formula_accordion
    accordion do
      card.hash_list.clone.map do |hash|
        metric = hash.delete :metric
        variable = hash.delete :name
        formula_accordion_item metric, variable, hash
      end
    end
  end

  private

  view :options_editor, template: :haml, unknown: true #, wrap: :modal

  def formula_accordion_item metric, variable, options
    metric_accordion_item metric do
      haml :formula_accordion_item, metric: metric, variable: variable, options: options
    end
  end

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
