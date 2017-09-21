format :html do
  def column_keys
    card.singleton_class::COLUMNS.keys
  end

  def column_titles
    card.singleton_class::COLUMNS.values
  end

  def table_rows_by_company_match_type
    rows_by_match_type =
      CompanyMatcher::MATCH_TYPE_ORDER.each_with_object({ invalid: [] }) do |(k, v), h|
        h[k] = []
      end
    @row_errors = {}

    card.csv_file.each_row do |row, i|
      row_data = card.csv_row_class.new row, i
      table_row = import_table_row_class.new row_data, self
      sort_key =
        if table_row.valid?
          table_row.match_type
        else
          @row_errors[table_row.csv_row.row_index] = table_row.csv_row.errors
          :invalid
        end
      rows_by_match_type[sort_key] << table_row.render
    end
    rows_by_match_type.values.flatten
  end

  def matches_companies?
    card.csv_row_class.ancestors.include? CSVRow::CompanyImport
  end

  def row_errors
    return "" unless @row_errors.present?
    alert(:danger, true) do
      with_header "Invalid data", level: 4 do
        @row_errors.each_with_object([]) do |(index, msgs), res|
          res << "##{index + 1}: #{msgs.join "; "}"
        end.join("<br/>")
      end
    end
  end

  def table_rows
    return table_rows_by_company_match_type if matches_companies?

    rows = []
    card.csv_file.each_row do |row, i|
      row_data = card.csv_row_class.new row, i
      rows << import_table_row_class.new(row_data, self).render
    end
    rows
  end

  def table_with_errors *args
    row_errors + table(*args)
  end

  view :import_table, cache: :never do |args|
    return alert(:warning) { "no import file attached" } if card.file.blank?
    table_with_errors(table_rows, class: "import_table table-hover",
                      header: column_titles)
  end

  # def row_to_hash row
  #   import_fields.each_with_object({}).with_index do |(key, hash), i|
  #     hash[key] = row[i]
  #     hash[key] &&= hash[key].force_encoding "utf-8"
  #   end
  # end
end
