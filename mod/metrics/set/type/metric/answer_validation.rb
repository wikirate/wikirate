def validate_all_values
  test = case value_type_code
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
  bad_answer = metric_card.all_answers.find do |answer|
    !valid_numeric_value? answer.value
  end
  "Non-numeric value: '#{bad_answer.value}'" if bad_answer.present?
end

def valid_numeric_value? value
  number?(value) || Answer.unknown?(value)
end
