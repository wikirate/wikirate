format :html do
  def default_import_table_args args
    args[:table_header] = ["Import", "#", "Company in File",
                           "Company in Wikirate", "Correction"]
    args[:table_fields] = [:checkbox, :row, :file_company, :wikirate_company, :correction]
  end

  view :import_table, cache: :never do |args|
    return alert(:warning) {"no import file attached"} if card.file.blank?

    rows_by_match_type = { exact: [], partial: [], alias: [], none: [] }
    card.csv_file.each_row do |row, i|
      row_data = csv_row_class.new row, i
      row = ImportRow.new row_data
      rows_by_match_type[row.match_type] << row.render
    end

    table_rows =
      CompanyMatcher::MATCH_TYPE_ORDER.keys.each_with_object([]) do |k, rows|
        rows += rows_by_match_type[k]
      end
    table table_rows, class: "import_table table-bordered table-hover",
                      header: args[:table_header]
  end

  def row_to_hash row
    import_fields.each_with_object({}).with_index do |(key, hash), i|
      hash[key] = row[i]
      hash[key] &&= hash[key].force_encoding "utf-8"
    end
  end
end
