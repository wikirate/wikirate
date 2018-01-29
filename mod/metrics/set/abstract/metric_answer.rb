card_accessor :value, type: :phrase
card_accessor :checked_by
card_accessor :source

def value
  virtual? ? content : value_card&.value
end

def raw_value
  if metric_type == :score
    metric_card&.basic_metric_card&.field(company)&.field(year)&.value
  else
    value
  end
end

