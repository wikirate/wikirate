# rubrics are used for scoring of categorical metrics

event :validate_rubric, :validate, on: :save, changed: :content do
  errors.add "invalid JSON" unless parse_content
  # errors.add "not all options mapped" if unmapped_option?
end

# converts a categorical formula content to an array
# @return [Array] list of pairs of value option and the value for that option
def translation_table
  parse_content.to_a
end

def complete_translation_table
  hash = parse_content
  metric_card.value_options.map { |option| [option, hash[option]] }
end

private

def unmapped_option?
  hash = parse_content
  metric_card.value_options.find { |option| !hash.key? option }
end

format :html do
  # @param [Array] table_content 2-dimensional array with the data for the
  # table; first row is the header
  def table_editor table_content, header=nil
    table(table_content, class: "pairs-editor", header: header) +
      _render_hidden_content_field
  end

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

