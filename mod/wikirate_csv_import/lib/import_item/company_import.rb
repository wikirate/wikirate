class ImportItem
  # To be used by ImportItem classes to handle company imports.
  # Expects
  #  - a company name in row[:company],
  #  - a suggestion (of the company mapper gem) for the corresponding company in the
  #    database in extra_data[:suggestion] and possibly a user correction of the mapping
  #    in extra_data[:corrections][:company].
  #    The user correction overrides the suggestion.
  module CompanyImport
    def import_company company_key=:company
      row_hash = { company_key => original_row[company_key] }
      company_csv = Structure::CompanyCsv.new row_hash, @row_index, @import_manager,
                                              company_key
      company_csv.import
      company_csv.company
    end
  end
end
