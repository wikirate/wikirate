#! no set module

# A metric value belongs to a metric and a company.
# If you select one of those two, then  MetricValuesHash manages all the related
# metrics values. That's either all metrics with all values for a given company
# or all companies with all values for a given metric.
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
    @primary_card = primary_card
    # used to fetch the primary and secondary name of a changed card
    @name_fetcher = name_fetcher
    hash_or_json = JSON.parse(hash_or_json) if hash_or_json.is_a?(String)
    replace hash_or_json
  end

  # @param changed_card [Card] a member of Type::MetricValue or
  #    TypePlusRight::MetricValue::Value
  def update changed_card
    prepare_for_change changed_card
    update_former_related
    update_related
  end

  # @param new_card [Card] a member of Type::MetricValue or
  #    TypePlusRight::MetricValue::Value
  def add new_card
    prepare_for_change new_card
    add_new_record
  end

  private

  def prepare_for_change changed_card
    @key_id = nil
    @changed_card = changed_card
  end

  def update_related
    return unless belongs_to_primary?
    @changed_card.trash? ? remove : add_or_update
  end

  # update values hash if @changed_card was a value of it before its
  # name changed (eg we collect all values for a metric and the metric
  # part in @changed_card's name changed)
  def update_former_related
    return unless belonged_to_primary?
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

  # the key use in the hash
  # it's the card id of the secondary part
  def key_id
    @key_id ||= fetch_key_id
  end

  def fetch_key_id former_name=false
    key_card_name = fetch_name_part :secondary, former_name
    return unless (key_card = Card[key_card_name])
    key_card.id.to_s
  end

  def with_former_key
    @key_id = fetch_key_id true
    yield
  ensure
    @key_id = nil
  end

  def belongs_to_primary? former_name=false
    changed_card_primary_name ||= fetch_name_part(:primary, former_name)
    @primary_card.name == changed_card_primary_name ||
      @primary_card.name.to_name.key == changed_card_primary_name.to_name.key
  end

  def belonged_to_primary?
    return unless @changed_card.name_changed?
    belongs_to_primary? true
  end

  def fetch_name_part which, former_name=false
    method_name = @name_fetcher[which]
    method_name += "_was" if former_name
    @changed_card.send method_name
  end

  def name_fetcher
    if @primary_card.type_code == :wikirate_company
      { primary: :company, secondary: :metric }
    else
      { primary: :metric, secondary: :company }
    end
  end
end
