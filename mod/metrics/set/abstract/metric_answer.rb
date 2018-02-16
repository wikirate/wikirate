card_accessor :value, type: :phrase
card_accessor :checked_by
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
