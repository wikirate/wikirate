format :html do
  def column_keys
    card.singleton_class::COLUMNS.keys
  end

  def column_titles
    card.singleton_class::COLUMNS.values
  end

  def row_errors
    return "" unless vm.errors?
    alert(:danger, true) do
      with_header "Invalid data", level: 4 do
        list_group vm.error_list
      end
    end
  end

  def validation_manager
    @vm ||= ValidationManager.new card.csv_file
  end

  alias_method :vm, :validation_manager
  delegate :already_imported?, to: :card

  def row_buckets
    row_buckets = {
      invalid: [],
      valid: [],
      imported: []
    }
  end

  def bucket_key table_row
    if already_imported? table_row.row_index
      :imported
    elsif table_row.status == :failed
      :invalid
    else
      :valid
    end
  end

  def table_rows
    rb = row_buckets
    vm.validate do |validated_csv_row|
      table_row = import_table_row_class.new validated_csv_row, self
      rb[bucket_key(table_row)] << table_row.render
    end
    rb.values.flatten
  end

  def table_with_errors *args
    row_errors + table(*args)
  end

  view :import_table, cache: :never do
    return alert(:warning) { "no import file attached" } if card.file.blank?
    table_with_errors(table_rows, class: "_import-table import-table table-hover",
                      header: column_titles)
  end

  def extra_data_input_name index, *subfields
    name = "extra_data[#{index}]"
    name << subfields.map { |f| "[#{f}]" }.join("") if subfields.present?
    name
  end

  def corrections_input_name index, key
    extra_data_input_name index, :corrections, key
  end
end
