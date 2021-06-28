card_accessor :formula, type: PhraseID
card_accessor :metric_variables
card_accessor :year, type: ListID # applicability

Card::Content::Chunk::FormulaInput # trigger load.  might be better place?

# @param company [cardish]
# @option years [String, Integer, Array] years to update value for (all years if nil)
def update_value_for! company, years=nil
  calculate_values_for company, years do |year, value|
    if (ans = answer_for company, year)
      update_existing_answer ans, value
    elsif value
      Answer.create_calculated_answer self, company, year, value
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

format :html do
  def table_properties
    super.merge year: "Years"
  end
end
