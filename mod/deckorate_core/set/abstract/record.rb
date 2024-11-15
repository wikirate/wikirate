card_accessor :discussion

def expire_left?
  false
end

# for speed, virtual card's _values_ are held both in the content of the _record_ card
# and in the value_card itself (using content is much faster)
def value
  virtual? ? content : value_card&.value
end

# used by lookup
def virtual_value_card lookup_value
  content = ::Record.value_from_lookup lookup_value, value_type_code
  Card.fetch [name, :value], eager_cache: true,
                             new: { content: content, type_code: value_cardtype_code }
end

# since real records require real values, it is assumed that new records
# (and only new records) will have new values
def fetch_value_card
  fetch :value, new: new_value_card_args
end

def value_card
  vc = fetch_value_card
  vc.content = content_from_value(value) if virtual?
  vc
end

def new_value_card_args
  { type_code: value_cardtype_code, supercard: self }
end

def numeric_value
  if metric_card.relation?
    value.to_i
  elsif metric_card.numeric?
    Record.to_numeric value
  end
end

# make sure pointer-style content works for multi-category
def content_from_value value
  Array.wrap(::Record.value_from_lookup(value, value_type_code)).join "\n"
end

def expire cache_type=nil
  super
  Card.expire [name, :value].to_name
end

# MISCELLANEOUS METHODS

def scored_record_card
  return self unless metric_type == :score

  metric_card&.scoree_card&.fetch(company)&.fetch(year)
end

# so that all fields show up in history
# (not needed when they can be identified via a more conventional form)
def history_card_ids
  field_card_ids << id
end

def field_card_ids
  %i[value checked_by source].map do |field|
    fetch(field, skip_virtual: true, skip_modules: true)&.id
  end.compact
end
