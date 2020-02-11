# include_set Abstract::TenScale

format :html do
  view :categorical_core do
    table categorical_content, header: %w[Value Score]
  end

  def categorical_content
    card.translation_table
    # TODO: following is preferable (colorifies the scores), but there are CSS problems
    # card.translation_table.map do |value, score|
    #   [value, colorify(score.to_s)]
    # end
  end

  view :categorical_editor do
    table_content = card.complete_translation_table.map do |key, value|
      [{ content: key, "data-key" => key }, text_field_tag("pair_value", value)]
    end
    table_editor table_content, %w[Option Value]
  end
end

event :validate_category_translation, :validate, when: :translate_formula? do
  # TODO: Check if there is a translation for all value options
end
