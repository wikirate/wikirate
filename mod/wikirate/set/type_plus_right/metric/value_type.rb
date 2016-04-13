
def all_numeric? metric_values
  metric_values.each do |_key, values|
    values.each do |mv|
      return false unless number?(mv['value'])
    end
  end
  true
end

def all_values_in_options? metric_values, options_card
  options = options_card.item_names content: options_card.content.downcase,
                                    context: :raw
  metric_values.each do |_key, values|
    values.each do |mv|
      return false unless options.include?(mv['value'].downcase)
    end
  end
  true
end

def show_category_option_errors options_card
  url = "/#{options_card.cardname.url_key}?view=edit"
  anchor =
    <<-HTML
      <a href='#{url}' target="_blank">add the values to options card</a>
    HTML
  errors.add :invalid_value, "Please #{anchor} first"
end

def related_values
  if (all_value_card = left.fetch trait: :all_values)
    all_value_card.cached_values
  end
end

event :validate_existing_values_type, :validate, on: :save do
  # validate the metric value while changing to number or category
  return unless db_content_changed?
  metric_name = cardname.left
  type = item_names[0]
  return unless (mv = related_values)
  case type
  when 'Number', 'Money'
    unless all_numeric?(mv)
      errors.add :invalid_value, 'Please check if all values are in number type'
    end
  when 'Category'
    options_card = Card.fetch "#{metric_name}+value_options", new: {}
    if (!mv.empty? && options_card.new?) ||
       !all_values_in_options?(mv, options_card)
      show_category_option_errors options_card
    end
  end
end
