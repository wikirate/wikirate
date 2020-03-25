class CsvRow
  module Structure
    # Specifies the structure of a csv row a metric answer import.
    class AnswerCsv < CsvRow
      include CsvRow::SourceImport
      include CsvRow::CompanyImport
      include CsvRow::AnswerImport

      @columns = [:metric, :wikirate_company, :year, :value, :source, :comment]
      @required = [:metric, :wikirate_company, :year, :value, :source]

      def import
        ImportLog.debug "answer import: #{@row}"
        import_answer
      end
    end
  end
end
