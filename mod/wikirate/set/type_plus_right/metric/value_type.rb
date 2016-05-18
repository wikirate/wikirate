
def invalid_metric_values metric_values
  invalid_metric_values = []
  metric_values.each do |key, values|
    values.each do |mv|
      if !number?(mv["value"]) && mv["value"].casecmp("unknown") != 0
        invalid_metric_values.push(mv.merge(company: key))
      end
    end
  end
  invalid_metric_values
end

def non_existing_values_in_options? metric_values, options_card
  options = options_card.item_names content: options_card.content.downcase,
                                    context: :raw
  non_existing_values = []
  metric_values.each do |_key, values|
    values.each do |mv|
      if !options.include?(mv["value"].downcase) &&
         mv["value"].casecmp("unknown") != 0
        non_existing_values.push(mv["value"])
      end
    end
  end
  non_existing_values
end

def show_category_option_errors options_card, invalid_options
  url = "/#{options_card.cardname.url_key}?view=edit"
  anchor =
    <<-HTML
      <a href='#{url}' target="_blank">add the values to options card</a>
    HTML
  values =
    if !invalid_options.nil?
      "\"#{invalid_options.uniq.join('\", \"')}\" is not an option for"\
      " this Metric."
    else
      ""
    end
  errors.add :value, "#{values} Please #{anchor} first."
end

def related_values
  if (all_value_card = left.fetch trait: :all_values)
    all_value_card.cached_values
  end
end

def handle_errors invalid_metric_values
  invalid_metric_values.each do |mv|
    errors.add "#{cardname.left}+#{mv[:company]}+#{mv[:year]}",
               "'#{mv[:value]}' is not a numeric value."
  end
end

event :validate_existing_values_type, :validate, on: :save do
  # validate the metric value while changing to number or category
  return unless db_content_changed?
  metric_name = cardname.left
  type = item_names[0]
  return unless (mv = related_values)
  case type
  when "Number", "Money"
    if (invalid_metric_values = invalid_metric_values(mv)) &&
       !invalid_metric_values.empty?
      handle_errors invalid_metric_values
    end
  when "Category"
    options_card = Card.fetch metric_name, :value_options, new: {}
    if (!mv.empty? && options_card.new?) ||
       (invalid_options = non_existing_values_in_options?(mv, options_card)) &&
       !invalid_options.empty?
      show_category_option_errors options_card, invalid_options
    end
  end
end
