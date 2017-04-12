require_relative "../../csv_import/csv_row"

class WikipediaCSVRow < CSVRow
  @required = [:wikirate_company_name, :wikirate_id,
               :wikipedia_company_page]

  def create
    puts @row[:wikirate_company_name]
    ensure_card [@row[:wikirate_id].to_i, :wikipedia],
                content: @row[:wikipedia_company_page],
                type_id: Card::PhraseID
  end
end
