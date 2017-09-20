format :html do
  def column_keys
    card.singleton_class::COLUMNS.keys
  end

  def column_titles
    card.singleton_class::COLUMNS.values
  end

  def table_rows_by_company_match_type
    rows_by_match_type =
      CompanyMatcher::MATCH_TYPE_ORDER.each_with_object({}) do |(k,v), h|
        h[k] = []
      end
    card.csv_file.each_row do |row, i|
      row_data = csv_row_class.new row, i
      table_row = import_table_row_class.new row_data, self
      rows_by_match_type[table_row.match_type] << table_row.render
    end
    rows_by_match_type.values.flatten
  end

  def matches_companies?
    csv_row_class.ancestors.include? CSVRow::CompanyImport
  end

  def table_rows
    return table_rows_by_company_match_type if matches_companies?

    rows = []
    card.csv_file.each_row do |row, i|
      row_data = csv_row_class.new row, i
      rows << import_table_row_class.new(row_data, self).render
    end
    rows
  end

  view :import_table, cache: :never do |args|
    return alert(:warning) {"no import file attached"} if card.file.blank?

    table table_rows, class: "import_table table-bordered table-hover",
                      header: column_titles
  end

  # def row_to_hash row
  #   import_fields.each_with_object({}).with_index do |(key, hash), i|
  #     hash[key] = row[i]
  #     hash[key] &&= hash[key].force_encoding "utf-8"
  #   end
  # end
end
