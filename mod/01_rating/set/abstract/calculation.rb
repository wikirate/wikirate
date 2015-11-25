card_accessor :formula, type_id: PhraseID

event :create_values,
      on: :create, before: :approve,
      when: proc { |c| c.formula.present? } do
  formula_card.calculate_all_values do |company, year, value|
    add_value company, year, score
  end
end

event :update_values,
      on: :update, before: :approve,
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
  Card.search right: 'value', left: { left: { left_id: id } }
end

def update_value_for! opts
  calculate_values_for(opts) do |year, value|
    metric_value_name = "#{name}+#{company}+#{year}"
    if (metric_value = Card[metric_value_name])
      if value
        if (value_card = metric_value.fetch trait: :value)
          value_card.update_attributes content: value
        else
          Card.create! name: "#{metric_value_name}+#{Card[:value].name}",
                       type_id: NumberID, content: value
        end
      else
        metric_value.delete
      end
    elsif value
      Card.create! name: metric_value_name,
                   type_id: MetricValueID,
                   subcards: {
                     '+value' => { type_id: NumberID, content: score }
                   }
    end
  end
end

def add_value company, year, value
  add_subfield "+#{company}+#{year}",
               # type_id: MetricValueID,
               # FIXME: can't use MetricValue because it needs a source
               subcards: {
                 '+value' => { type_id: NumberID, content: value }
               }
end
