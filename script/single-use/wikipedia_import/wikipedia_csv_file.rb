require_relative "../../csv_import/csv_file"
require_relative "wikipedia_csv_row"

class WikipediaCSVFile < CSVFile
  @columns =
    [:wikirate_company, :wikirate_company_id, :wikipedia_url]

  def process_row row
    WikipediaCSVRow.new(row).create
  end
end
