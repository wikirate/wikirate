require_relative "../../csv_import/csv_row"

class MetricCSVRow < CSVRow
  @required = [:wikirate_company, :wikirate_company_id, :wikipedia_url]

  def initialize row
    @value_details = {}
    super
    @designer = @row.delete :metric_designer
    @title = @row.delete :metric_title
    @name = "#{@designer}+#{@title}"
    @row[:wikirate_topic] = @row.delete :topics if @row[:topics]
  end

  def create
    ensure_card [@row[:wikirate_company_id], :wikipedia],
                content: @row[wikipedia_url],
                type_id: Card::PhraseID
  end
end
