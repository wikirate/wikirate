JOINT = ", "

def value_card
  self
end

def value
  content
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

def record
  name.parts[0..-3].join "+"
end

def record_card
  Card.fetch record
end

format :html do
  def default_item_view
    :name
  end

  def pretty_value
    @pretty_value ||= card.value
  end
end

format :json do
  view :content do
    card.value
  end
end

format :csv do
  view :content do
    card.value
  end
end
