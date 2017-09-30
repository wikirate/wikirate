require_relative "csv_row"
require_relative "csv_row/source_import"

# Create a source described by a row in a csv file.
class SourceCSVRow < CSVRow
  include CSVRow::SourceImport
  include CSVRow::CompanyImport

  @columns = [:company, :year, :report_type, :source, :title]
  @required = [:company, :year, :report_type, :source]

  def finalize_source_card source_card
    with_sourcebox do
      source_card.director.catch_up_to_stage :prepare_to_store
    end
  end

  def import
    check_duplication_within_file
    import_company
    import_source
  end
end
