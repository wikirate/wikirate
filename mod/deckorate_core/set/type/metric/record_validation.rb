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
  bad_record = metric_card.answers.find do |answer|
    !valid_numeric_value? answer.value
  end
  t :answer_validation_error_message, bad_record: bad_record.value if bad_record.present?
end

def valid_numeric_value? value
  value.to_s.number? || Answer.unknown?(value)
end
