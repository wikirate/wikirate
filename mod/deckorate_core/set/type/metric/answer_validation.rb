def validate_all_values
  test = case simple_value_type_code
         when :number, :money            then :numeric
         when :category, :multi_category then :categorical
         else                            return
         end
  send "validate_all_#{test}_values"
end

def validate_all_categorical_values
  validator = CategoryValueValidator.new self
  validator.error_msg if validator.invalid_values?
end

def validate_all_numeric_values
  bad_answer = metric_card.answers.find do |answer|
    !valid_numeric_value? answer.value
  end
  if bad_answer.present?
    return "ERROR: Unable to change answer type to Number."\
           " REASON: Non-numeric value: found in existing answers"\
           " ('#{bad_answer.value}'). Please update or delete all"\
           " answers containing '#{bad_answer.value}' before changing"\
           " the answer type to Number."
end

def valid_numeric_value? value
  value.to_s.number? || Answer.unknown?(value)
end
