require_relative "../../csv_row"

class WikipediaCSVRow < CSVRow
  @columns = [:wikirate_company_name, :wikirate_id, :wikipedia_company_page]
  @required = :all

  def initialize row
    super
    @row[:wikipedia_company_page] =~ %r{/([^/]+)$}
    @wikipedia_name = Regexp.last_match(1)
    @company_id = @row[:wikirate_id].to_i
  end

  def create
    puts @row[:wikirate_company_name]
    ensure_card [@company_id, :wikipedia],
                content: @wikipedia_name,
                type_id: Card::PhraseID
  end
end
