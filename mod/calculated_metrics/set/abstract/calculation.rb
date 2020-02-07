card_accessor :formula, type_id: Card::PhraseID
card_accessor :metric_variables

# @param [Hash] opts
# @option opts [card key] :company
# @option opts [String] :year
def update_value_for! opts
  calculate_values_for(opts) do |year, value|
    if (ans = answer_for opts[:company], year)
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
    value ? answer.update_value(value) : delete_calculated_answer(answer)
  end
  refresh_answer_card answer.card
end

def refresh_answer_card answer
  answer.instance_variable_set "@answer", nil
  answer.expire
end

def delete_calculated_answer answer
  answer.destroy
  answer.update_cached_counts
end

def update_overridden_calculated_value answer, value
  answer.update! overridden_value: value
  answer.overridden_value_card.update! content: value
end

def already_researched? answer
  !answer.virtual?
end

def normalize_value value
  ::Answer.value_to_lookup value
end
