class CSVRow
  # To be used by CSVRow classes to handle company imports.
  # Expects
  #  - a company name in row[:company],
  #  - a suggestion (of the company mapper gem) for the corresponding company in the
  #    database in extra_data[:suggestion] and possibly a user correction of the mapping
  #    in extra_data[:corrections][:company].
  #    The user correction overrides the suggestion.
  module CompanyImport
    def import_company
      row_hash = { company: original_row[:company] }
      company_csv  =
        Structure::CompanyCSV.new(row_hash, @row_index, @import_manager)
      company_csv.import
    end
  end
end
