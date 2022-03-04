format :html do
  view :formula_core do
    table formula_core_table_rows, header: %w[Variable Metric Options]
  end

  # TODO: refactor with wiki_rating_input
  def formula_input
    with_nest_mode :normal do
      class_up "card-slot", filtered_list_slot_class
      wrap do
        [formula_editor_table,
         render_hidden_content_field,
         add_item_modal_link]
      end
    end
  end

  private

  def formula_editor_table
    table formula_editor_table_content, class: "_variablesEditor",
          header: %w[Variable Metric Options]
  end

  def formula_editor_table_content
    card.hash_list.map do |var|
      subformat(var[:metric]).formula_variable_row var
    end.compact
  end

  ## core view

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
