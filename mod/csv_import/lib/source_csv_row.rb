require_relative "csv_row"
require_relative "csv_row/source_import"

# create a metric answer described by a row in a csv file
class SourceCSVRow < CSVRow
  include CSVRow::SourceImport
  include CSVRow::CompanyImport

  @columns =
    [:company, :year, :report_type, :source, :title]

  @required =  [:company, :year, :source, :report_type]

  def finalize_source_card source_card
      Env.params[:sourcebox] = "true"
      source_card.director.catch_up_to_stage :prepare_to_store
      Env.params[:sourcebox] = nil
      source_card
  end

  def import
    check_duplication_within_file
    import_company
    import_source
  end
end
