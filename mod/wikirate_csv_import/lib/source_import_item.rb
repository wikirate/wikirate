
# create a source described by a row in a csv file
class SourceImportItem < ImportItem
  @columns = { wikirate_company: {},
               year: {},
               report_type: {},
               source: {},
               title: { optional: true } }

  def import_hash
    {
      type_id: Card::SourceID,
      "+File" =>         { remote_file_url: source, type_id: Card::FileID },
      "+title" =>        { content: title },
      "+report_type" =>  { content: "[[#{report_type}]]" },
      "+company" =>      { content: "[[#{wikirate_company}]]" },
      "+year" =>         { content: "[[#{year}]]" }
    }
  end
end
