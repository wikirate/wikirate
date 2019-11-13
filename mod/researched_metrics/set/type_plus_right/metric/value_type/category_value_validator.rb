#! no set module

# This class is used for changing the value type of a metric to "category".
# It Checks if all existing answers have valid options for the categorical metric.
class CategoryValueValidator
  attr_reader :keys

  def initialize metric_card
    @metric_card = metric_card
    @value_options = @metric_card.value_options
    initialize_values
    initialize_keys
  end

  def initialize_values
    @values = Answer.where(metric_id: @metric_card.id).select(:value).distinct
    if @metric_card.multi_categorical?
      @values = @values.map { |v| v.split ", " }.flatten.uniq
    end
  end

  def initialize_keys
    @key_to_name ||= {}
    @keys = @values.map do |n|
      key = n.value.to_name.key
      @key_to_name[key] = n.value
      key
    end
  end

  def invalid_values?
    invalid_count.positive?
  end

  def invalid_count
    invalid_keys.size
  end

  def invalid_keys
    @invalid_keys ||= keys - valid_category_keys
  end

  def invalid_values
    invalid_keys.map do |k|
      link_to_answer(name(k)).html_safe
    end
  end

  def name key
    @key_to_name[key]
  end

  def valid_category_keys
    keys = @value_options.map { |n| n.to_name.key }
    keys << "unknown"
  end

  def error_msg
    msg =
      if invalid_count == 1
        "#{invalid_values.to_sentence} is not a valid option for this metric. "\
        "Please add this option."
      else
        "#{invalid_values.to_sentence} are not valid options for this metric. "\
        "Please add those options."
      end
    msg + " #{link_to_edit_options} first."
  end

  def link_to_answer value
    @metric_card.format.link_to_card(@metric_card, value,
                                     path: { filter: { value: [value] } })
  end

  def link_to_edit_options
    @metric_card.format.link_to_card @metric_card.value_options_card,
                                     "to the options card",
                                     path: { view: :edit }, target: "_blank"
  end
end
