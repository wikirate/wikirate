require_relative "../../csv_import/csv_row"

class WikipediaCSVRow < CSVRow
  @required = [:wikirate_company_name, :wikirate_id,
               :wikipedia_company_page]

  def create
    ensure_card [@row[:wikirate_id], :wikipedia],
                content: @row[:wikipedia_company_page],
                type_id: Card::PhraseID
  end
end
