# handles formulas that translates values, i.e. there is one-to-one
# relation between input value and calculataed value like
#  - a Score Metric for a researched metrics with value type Category
#  - WikiRatings that assign a weight to each input value

# converts a categorical formula content to an array
# @return [Array] list of pairs of value option and the value for that option
def translation_table
  translation_hash.to_a
end

def translation_hash
  return {} unless content.present?
  JSON.parse(content)
rescue JSON::ParserError => _e
  content = "{}"
  return {}
  # fail Card::Error, 'fail to parse formula for categorical input'
end

def complete_translation_table
  translation = translation_table
  all_options = if score?
                  metric_card.basic_metric_card.value_options
                else
                  metric_card.value_options
                end
  if all_options
    missing_options = all_options - translation_hash.keys
    translation += missing_options.map { |opt| [opt, ""] }
  end
  translation
end

format :html do
  # @param [Array] table_content 2-dimensional array with the data for the
  # table; first row is the header
  def table_editor table_content, header=nil
    table(table_content, class: "pairs-editor", header: header) +
      _render_hidden_content_field
  end
end
