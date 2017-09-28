format :html do
  def column_keys
    card.singleton_class::COLUMNS.keys
  end

  def column_titles
    card.singleton_class::COLUMNS.values
  end

  def row_errors
    return "" unless vim.errors?
    alert(:danger, true) do
      with_header "Invalid data", level: 4 do
        list_group vim.error_list
      end
    end
  end

  def validation_manager
    @vim ||= ValidationImportManager.new card.csv_file
  end

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
    vim.validate do |validated_csv_row|
      table_row = import_table_row_class.new validated_csv_row, self
      rb[bucket_key(table_row)] << table_row.render
    end
    rb.values.flatten
  end
end

def table_with_errors *args
  row_errors + table(*args)
end

view :import_table, cache: :never do |args|
  return alert(:warning) { "no import file attached" } if card.file.blank?
  table_with_errors(table_rows, class: "import_table table-hover",
                    header: column_titles)
end

def already_imported? index
  imported_rows_card.already_imported? index
end
