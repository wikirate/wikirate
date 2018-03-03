VALID_INPUT_TYPE_IDS = [MetricID, YearlyVariableID].freeze

def clean_formula
  descendant? ? inheritance_formula : standard_formula
end

def standard_formula
  content.gsub /[\r\n]+/m, ""
end

def input_chunks
  @input_chunks ||= find_input_chunks
end

def find_input_chunks
  content_obj = Card::Content.new(content, self, chunk_list: :formula)
  content_obj.find_chunks(Content::Chunk::FormulaInput)
end

def input_cards
  @input_cards ||= input_names.map { |name| Card.fetch name }
end

def input_names
  @input_names ||=
    case metric_card.metric_type_codename
    when :score       then [metric_card.basic_metric]
    when :wiki_rating then translation_hash.keys
    when :descendant  then item_names
    else                   standard_input_names
    end
end

def standard_input_names
  input_chunks.map { |chunk| chunk.referee_name.to_s }
end

def input_keys
  @input_keys ||= input_names.map { |m| m.to_name.key }
end

event :validate_formula_input, :validate, on: :save, changed: :content do
  input_chunks.each do |chunk|
    ok_input_name(chunk) && ok_input_card(chunk) && ok_input_cardtype(chunk)
  end
end

def ok_input_name chunk
  ok_input? variable_name?(chunk.referee_name) do
    "invalid variable name: #{chunk.referee_name}"
  end
end

def ok_input_card chunk
  ok_input? chunk.referee_card do
    "input metric #{chunk.referee_name} doesn't exist"
  end
end

def ok_input_cardtype chunk
  ok_input? VALID_INPUT_TYPE_IDS.include?(chunk.referee_card.type_id) do
    "#{chunk.referee_name} has invalid type #{chunk.referee_card.type_name}"
  end
end

def ok_input? test
  return true if test
  errors.add :formula, yield
  false
end
