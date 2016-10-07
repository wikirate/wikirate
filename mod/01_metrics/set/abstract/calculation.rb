card_accessor :formula, type_id: PhraseID

# @param [Hash] opts
# @option opts [card key] :company
# @option opts [String] :year
def update_value_for! opts
  formula_card.calculate_values_for(opts) do |year, value|
    value_name = metric_value_name opts[:company], year
    if (metric_value = Card[value_name])
      if value
        update_value_card metric_value, value
      else
        metric_value.delete
      end
    elsif value
      create_value_card value_name, value
    end
  end
end

# TODO: move these methods to metric_value set ?
def update_value_card value_card, value
  if (value_value_card = value_card.fetch trait: :value)
    value_value_card.update_attributes content: value
  else
    Card.create! name: "#{value_card.name}+#{Card[:value].name}",
                 type_id: NumberID, content: value
  end
end

def create_value_card name, value
  Card.create! name: name, type_id: MetricValueID,
               subcards: { "+value" => { type_id: NumberID, content: value } }
end

def normalize_value value
  value.to_s if value
end
