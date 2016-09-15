class CachedValues < Hash
  def initialize json_hash
    replace JSON.parse(json_hash)
  end

  def update changed_card
    @changed_card = changed_card
    # name changed?
    if changed_card.name_changed? && !changed_card.name_change.include?(nil)
      add_or_remove_value
    else
      cud_value_from_hash
    end
  end

  private

  def cud_value_from_hash
    if  @changed_card.trash?
      # value created or deleted or update
      # remove it from the cache
      remove_value_from_hash @changed_card
    else
      # find if it exists in cache
      # exist -> update
      # not exist -> add one
      add_or_update_value @changed_card
    end
  end

  def add_or_remove_value
    new_metric = extract_name(@changed_card, :metric)
    if new_metric == metric
      # remove value from the same cache
      remove_value_from_hash
      add_value_to_hash
    else
      remove_value_from_hash
    end
  end

  def get_record_from_year records, year
    record = records.select { |row| row["year"] == year }
    record.empty? ? nil : record[0]
  end

  def get_value_card
    if @changed_card.type_id == Card::MetricValueID
      @changed_card.fetch trait: :value
    else
      @changed_card
    end
  end

  def add_or_update_value
    company_id = get_key @changed_card
    self[company_id] = [] unless cached_hash.key?(company_id)
    rows = self[company_id]
    row = get_record_from_year(rows, @changed_card.year)
    value_card = get_value_card @changed_card

    if rows.empty? || row.nil?
      rows.push construct_a_row(value_card)
    else
      row[:value] = value_card.value
    end
  end

  def add_value_to_hash
    company_id = get_key @changed_card
    self[company_id] = [] unless key?(company_id)
    value_card = get_value_card @changed_card
    self[company_id].push construct_a_row(value_card)
  end

  def remove_value_from_hash
    company_id = get_key @changed_card, @changed_card.trash? ? :new : :old
    values = self[company_id]
    return unless values
    values.delete_if { |row| row["year"] == @changed_card.year }
    delete company_id if values.empty?
  end

end
