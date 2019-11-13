def validate_all_values from
  test = case value_type_code
         when :number, :money then :numeric
         when :category, :multi_category then :categorical?
         end
  error_message = send "validate_all_#{test}_values"
  from.errors.add :answers, error_message if error_message
end

def validate_all_categorical_values
  validator = CategoryValueValidator.new self
  validator.error_msg if validator.invalid_values?
end

def validate_all_numeric_values
  bad_values = []
  metric_card.researched_answers.find do |answer|
    bad_values << answer.value if valid_numeric_value? answer.value
  end
  "Non-numeric value(s): #{bad_values.join ', '}" if bad_values.present?
end

def valid_numeric_value? value
  number?(value) || Answer.unknown?(value)
end
