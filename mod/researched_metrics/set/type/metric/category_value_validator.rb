#! no set module

# This class is used for changing the value type of a metric to "category".
# It Checks if all existing answers have valid options for the categorical metric.
class CategoryValueValidator
  attr_reader :keys

  def initialize metric_card
    @metric_card = metric_card
    @valid_values = @metric_card.value_options + ["Unknown".to_name]
    initialize_values
  end

  def initialize_values
    @values = Answer.where(metric_id: @metric_card.id).distinct.pluck(:value)
    return unless @metric_card.multi_categorical?

    @values = @values.map { |v| v.split ", " }.flatten.uniq.map(&:name)
  end

  def invalid_values?
    invalid_count.positive?
  end

  def invalid_count
    invalid_values.size
  end

  def invalid_values
    @invalid_values ||= @values - @valid_values
  end

  def error_msg
    "The following values appear in answers " \
    "but are not listed as valid options: #{invalid_values.to_sentence}"
  end
end
