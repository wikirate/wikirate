require_relative "../../csv_import/csv_row"

class WikipediaCSVRow < CSVRow
  @required = [:wikirate_company_name, :wikirate_id,
               :wikipedia_company_page]

  def initialize row
    super
    @row[:wikipedia_company_page] =~ %r{/([^/]+)$}
    @wikipedia_name = Regexp.last_match(1)
  end

  def create
    puts @row[:wikirate_company_name]
    ensure_card [@row[:wikirate_id].to_i, :wikipedia],
                content: @wikipedia_name,
                type_id: Card::PhraseID
  end
end
