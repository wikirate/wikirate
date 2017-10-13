require_relative "../csv_row"

# create a source described by a row in a csv file
class SourceCSVRow < CSVRow
  @columns = [:company, :year, :report_type, :source, :title]
  @required = [:company, :year, :report_type, :source]

  def import
    ensure_company
    create_source
  end

  def create_source
    puts company
    Card.create! name: "", type_id: Card::SourceID, subcards: source_args
  end

  def source_args
    {
      "+*source_type" => { content: "[[Link]]" },
      "+Link" =>         { content: source, type_id: Card::PhraseID },
      "+title" =>        { content: title },
      "+report_type" =>  { content: "[[#{report_type}]]" },
      "+company" =>      { content: "[[#{company}]]" },
      "+year" =>         { content: "[[#{year}]]" }
    }
  end

  def ensure_company
    return if Card[company]
    Card.create! name: company, type_id: Card::WikirateCompanyID
  end
end
