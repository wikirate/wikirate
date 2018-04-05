card_accessor :value, type: :phrase
card_accessor :checked_by
card_accessor :check_requested_by
card_accessor :source

def value
  virtual? ? content : value_card&.value
end

alias_method :real_value_card, :value_card

def value_card
  vc = real_value_card
  vc.content = value if virtual?
  vc
end

def raw_value
  if metric_type == :score
    metric_card&.basic_metric_card&.field(company)&.field(year)&.value
  else
    value
  end
end

# MISCELLANEOUS METHODS
def currency
  (metric_card.value_type == "Money" && metric_card.currency) || nil
end

def history_card_ids
  field_card_ids << id
end

def field_card_ids
  [:value, :checked_by, :source, :check_requested_by].map do |field|
    fetch(trait: field, skip_virtual: true, skip_modules: true)&.id
  end.compact
end