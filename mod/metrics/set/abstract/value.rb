JOINT = ", "

def value_card
  self
end

def value
  raw_value.join JOINT
end

def raw_value
  item_names context: :raw
end

def unknown_value?
  Answer.unknown? content
end

def overridden_value?
  left&.answer&.virtual?
end

def metric_key
  metric.to_name.key
end

def company_key
  company.to_name.key
end

def company_id
  Card.fetch_id company_key
end

# def record
#   name.parts[0..-3].join "+"
# end
#
# def record_card
#   Card.fetch record
# end
