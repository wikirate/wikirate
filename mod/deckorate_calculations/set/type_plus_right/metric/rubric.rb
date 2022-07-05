include_set Abstract::MetricChild, generation: 1
include_set Abstract::TenScale
include_set Abstract::CalcTrigger

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
  hash = content.present? ? parse_content : {}
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
  COLUMNS = %w[Value Score].freeze

  view :core do
    table categorical_content, header: COLUMNS
  end

  view :input, cache: :never do
    table_content = card.complete_translation_table.map do |key, value|
      [{ content: key, "data-key" => key }, text_field_tag("pair_value", value)]
    end
    table_editor table_content, COLUMNS
  end

  private

  def categorical_content
    card.translation_table.map do |value, score|
      score = score.to_s
      score = colorify score unless card.metric_card.multi_categorical?
      # if score is one of many categories, then its score is often a partial value,
      # so the color mapping doesn't make sense.  Eg, each of five values might be
      # worth two points each, but the color associate with 2 implies a bad score
      [value, score]
    end
  end

  # @param [Array] table_content 2-dimensional array with the data for the
  # table; first row is the header
  def table_editor table_content, header=nil
    table(table_content, class: "pairs-editor", header: header) +
      _render_hidden_content_field
  end
end
