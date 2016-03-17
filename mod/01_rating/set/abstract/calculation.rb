  card_accessor :formula, type_id: PhraseID

event :create_values, :prepare_to_validate,
      on: :create,
      when: proc { |c| c.formula.present? } do

  # FIXME: formula_card.left has type metric at this points but
  #        formula_card.set_names includes "Basic+formula+*type plus right"
  formula_card.reset_patterns
  formula_card.include_set_modules
  formula_card.calculate_all_values do |company, year, value|
    add_value company, year, value
  end
end

event :update_values, :prepare_to_validate,
      on: :update,
      when: proc { |c| c.formula.present? } do
  value_cards.each do |value_card|
    value_card.trash = true
    add_subcard value_card
  end

  formula_card.calculate_all_values do |company, year, value|
    if (card = subfield "+#{company}+#{year}+value")
      card.trash = false
      card.content = value
    else
      add_value company, year, value
    end
  end
end

def value_cards
  Card.search right: 'value', left: { left: { left: name } }
end

def update_value_for! opts
  formula_card.calculate_values_for(opts) do |year, value|
    metric_value_name = "#{name}+#{opts[:company]}+#{year}"
    if (metric_value = Card[metric_value_name])
      if value
        update_value_card metric_value, value
      else
        metric_value.delete
      end
    elsif value
      create_value_card metric_value_name, value
    end
  end
end

#TODO move these methods to metric_value set ?
def update_value_card value_card, value
  if (value_value_card = value_card.fetch trait: :value)
    value_value_card.update_attributes content: value
  else
    Card.create! name: "#{value_card.name}+#{Card[:value].name}",
                 type_id: NumberID, content: value
  end
end

def create_value_card name, value
  Card.create! name: name,
               type_id: MetricValueID,
               subcards: {
                 '+value' => { type_id: NumberID, content: value }
               }
end

def add_value company, year, value
  add_subfield "+#{company}+#{year}",
               # type_id: MetricValueID,
               # FIXME: can't use MetricValue because it needs a source
               subcards: {
                 '+value' => { type_id: NumberID, content: value }
               }
end
