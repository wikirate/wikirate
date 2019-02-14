include_set Abstract::Pointer
include_set Abstract::Value

event :validate_valid_categories, :validate, on: :save do
  invalid_options = illegal_items
  return true if Answer.unknown?(value) || invalid_options.empty?
  url = "/#{options_card.name.url_key}?view=edit"
  anchor = %(<a href='#{url}' target="_blank">add that option</a>)
  errors.add :content, "invalid option(s): #{invalid_options.join ', '}. " \
                     "Please #{anchor} before adding this metric value."
end

def illegal_items
  option_keys = standard_option_names.map(&:key)
  raw_value.reject { |item| option_keys.member? item.key }
end

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

format :html do
  def editor
    options_count > 10 ? :select : :radio
  end

  def pretty_value
    card.pretty_values.join ", <br>"
  end

  private

  def options_count
    card.option_names.size
  end
end
