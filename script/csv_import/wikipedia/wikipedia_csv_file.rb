require_relative "../../csv_file"
require_relative "wikipedia_csv_row"

class WikipediaCSVFile < CSVFile
  @columns = [:wikirate_company_name, :wikirate_id, :wikipedia_company_page]

  def process_row row
    WikipediaCSVRow.new(row).create
  end
end
