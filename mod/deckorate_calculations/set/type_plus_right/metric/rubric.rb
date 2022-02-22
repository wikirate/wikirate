include_set Abstract::MetricChild, generation: 1
include_set Abstract::TenScale

# rubrics are used for scoring of categorical metrics

event :validate_rubric, :validate, on: :save, changed: :content do
  errors.add "invalid JSON" unless parse_content
  # errors.add "not all options mapped" if unmapped_option?
end

event :recalculate_on_rubric_change, :integrate_with_delay,
      on: :save, changed: :content, priority: 5, when: :content? do
  metric_card.deep_answer_update
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

def translation_hash
  JSON.parse content.downcase
end

private

def unmapped_option?
  hash = parse_content
  metric_card.value_options.find { |option| !hash.key? option }
end

format :html do
  COLUMNS = %w[Value Score]

  view :core do
    table categorical_content, header: COLUMNS
  end

  view :input do
    table_content = card.complete_translation_table.map do |key, value|
      [{ content: key, "data-key" => key }, text_field_tag("pair_value", value)]
    end
    table_editor table_content, COLUMNS
  end

  private

  def categorical_content
    card.translation_table.map do |value, score|
      [value, colorify(score.to_s)]
    end
  end

  # @param [Array] table_content 2-dimensional array with the data for the
  # table; first row is the header
  def table_editor table_content, header=nil
    table(table_content, class: "pairs-editor", header: header) +
      _render_hidden_content_field
  end
end
