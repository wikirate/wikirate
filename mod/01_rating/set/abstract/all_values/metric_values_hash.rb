#! no set module

# # A metric value belongs to a metric and a company.
# If you select one of those two MetricValuesHash manages all the related
# metrics values. That's either all metrics with all values for a given company
# or all companies with values for a given metric.
#
# The metric values are saved in the following format
#   { company_id/metric_id (as string) =>
#     [{ "year" => , "value" => , "last_update_time => }], ...
#   }
class MetricValuesHash < Hash
  # @param primary_card [Card] a metric or company card
  # @param hash_or_json [Hash, String] with format
  #   { company/metric id =>
  #       [{ "year" => , "value" => , "last_update_time => }], ...
  #   }
  # @example for a fixed metric
  def initialize primary_card, hash_or_json={}
    @primary_name = primary_card.name
    @primary_type = primary_card.type_code
    @secondary_type = @primary_type == :metric ? :company : :metric
    hash_or_json = JSON.parse(hash_or_json) if hash_or_json.is_a?(String)
    replace hash_or_json
  end

  # @param changed_card [Card] a member of Type::MetricValue or
  #    TypePlusRight::MetricValue::Value
  def update changed_card
    @changed_card = changed_card
    update_former_related
    update_related
  end

  # @param new_card [Card] a member of Type::MetricValue or
  #    TypePlusRight::MetricValue::Value
  def add new_card
    @changed_card = new_card
    add_new_record
  end

  private

  def update_related
    return unless @primary_name == @changed_card.send(@primary_type)
    @changed_card.trash? ? remove : add_or_update
  end

  def update_former_related
    return unless @changed_card.name_changed? &&
                  @primary_name == @changed_card.send("#{@primary_type}_was")
    with_former_key do
      remove @changed_card.year_was
    end
  end

  def add_or_update
    if changed_record
      changed_record[:value] = @changed_card.value
    else
      add_new_record
    end
  end

  def remove year=@changed_card.year
    return unless records?
    records.delete_if { |row| row["year"] == year }
    delete company_id if records.empty?
  end

  def changed_record
    return unless records?
    @changed_record ||=
      records.find { |row| row["year"] == @changed_card.year }
  end

  def add_new_record
    return unless key_id
    records << construct_record
  end

  def records
    self[key_id] ||= []
  end

  def records?
    return unless key_id
    self[key_id]
  end

  def construct_record
    value_card = @changed_card.value_card
    { year: value_card.year,
      value: value_card.value,
      last_update_time: value_card.updated_at.to_i }
  end

  def key_id
    @key_id ||= fetch_key_id
  end

  def fetch_key_id former_name=false
    name_reader = former_name ? "#{@secondary_type}_was" : @secondary_type
    key_card_name = @changed_card.try(name_reader)
    return unless (key_card = Card[key_card_name])
    key_card.id.to_s
  end

  def with_former_key
    @key_id = fetch_key_id true
    yield
  ensure
    @key_id = nil
  end
end
