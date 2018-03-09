format :html do
  view :categorical_core do |_args|
    table card.translation_table, header: %w[Value Score]
  end

  view :categorical_editor do |_args|
    table_content = card.complete_translation_table.map do |key, value|
      [{ content: key, "data-key" => key }, text_field_tag("pair_value", value)]
    end
    table_editor table_content, %w[Option Value]
  end
end

event :validate_category_translation, :validate, when: :translate_formula? do
  # TODO: Check if there is a translation for all value options
end
