event :validate_metric_value_fields, before: :set_metric_value_name do
  %w(metric company year value).each do |name|
    unless subfield_exist?(name)
      errors.add :field, "Missing #{name}. Please check before submit."
    end
  end
end

event :validate_value_type, :validate, on: :save do
  # check if the value fit the value type of metric
  if metric_card && (value_type = metric_card.fetch(trait: :value_type)) &&
     (value_card = subfield(:value))
    value = value_card.content
    return if value.casecmp("unknown").zero?
    case value_type.item_names[0]
    when "Number", "Money"
      unless number?(value)
        errors.add :value, "Only numeric content is valid for this metric."
      end
    when "Category"
      # check if the value exist in options
      if !(option_card = Card["#{metric_card.name}+value options"]) ||
         !option_card.item_names.include?(value)
        url = "/#{option_card.cardname.url_key}?view=edit"
        anchor = %(<a href='#{url}' target="_blank">add options</a>)
        errors.add :value, "Please #{anchor} before adding metric value."
      end
    end
  end
end

def number? str
  true if Float(str)
rescue
  false
end
