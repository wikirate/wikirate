JOINT = ", "

def value_card
  self
end

def value
  content
end

def unknown_value?
  ::Answer.unknown? content
end

def metric_key
  metric.to_name.key
end

def company_key
  company.to_name.key
end

def company_id
  company_key.card_id
end

def record
  name.parts[0..-3].join "+"
end

def record_card
  Card.fetch record
end

def view_cache_clean?
  true
end

def current_route_symbol
  return unless db_content_is_changing?

  if import_act?
    :import
  elsif Card::Auth.api_act?
    :api
  else
    :direct
  end
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
