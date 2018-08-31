card_accessor :checked_by
card_accessor :check_requested_by
card_accessor :source

# for hybrid metrics: If a calculated value is overridden by a researched value
#   then :overridden_value holds on to that value. It also serves as flag to mark
#   overridden answers
card_accessor :overridden_value, type: :phrase

def value
  virtual? ? content : value_card&.value
end

def fetch_value_card
  new_args = new? ? { type_code: value_cardtype_code } : {}
  fetch trait: :value, new: new_args
end

def value_card
  vc = fetch_value_card
  vc.content = value if virtual?
  vc
end

def value_cardtype_code
  :"#{metric_card.value_type_code}_value"
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

# so that all fields show up in history
# (not needed when they can be identified via a more conventional form)
def history_card_ids
  field_card_ids << id
end

def field_card_ids
  [:value, :checked_by, :source, :check_requested_by].map do |field|
    fetch(trait: field, skip_virtual: true, skip_modules: true)&.id
  end.compact
end
