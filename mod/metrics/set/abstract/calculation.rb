card_accessor :formula, type_id: PhraseID
card_accessor :metric_variables

# @param [Hash] opts
# @option opts [card key] :company
# @option opts [String] :year
def update_value_for! opts
  formula_card.calculate_values_for(opts) do |year, value|
    if (ans = answer opts[:company], year)
      update_existing_answer ans, value
    elsif value
      Answer.create_calculated_answer self, opts[:company], year, value
    end
  end
end

def update_existing_answer answer, value
  if already_researched? answer
    update_overridden_calculated_value answer, value
  else
    value ? answer.update_value(value) : answer.destroy
  end
  answer.card.instance_variable_set("@answer", nil)
end

def update_overridden_calculated_value answer, value
  answer.update_attributes! overridden_value: value
  answer.overridden_value_card.update_attributes! content: value
end

def already_researched? answer
  !answer.virtual?
end

def normalize_value value
  value.to_s if value
end
