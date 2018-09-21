include_set Abstract::Pointer
include_set Abstract::Value

def value
  raw_value.join JOINT
end

def raw_value
  item_names context: :raw
end

def inverted_options_hash
  options_hash.each_with_object({}) do |(k, v), h|
    h[v] = k
  end
end

def pretty_values
  json_options? ? raw_values_from_hash : raw_value
end

def raw_values_from_hash
  hash = inverted_options_hash
  item_names.map { |item| hash[item] }
end

def options_card
  Card.fetch metric, :value_options, new: {}
end

def option_names
  options_card.item_names context: :raw
end

format :html do
  def editor
    options_count > 10 ? :select : :radio
  end

  def pretty_value
    card.pretty_values.join ", "
  end

  private

  def options_count
    card.option_names.size
  end
end
