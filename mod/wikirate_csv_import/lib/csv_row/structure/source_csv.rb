class CsvRow
  module Structure
    # Specifies the structure of a csv row for a source import.
    class SourceCSV < CsvRow
      require "csv_row"
      require "csv_row/source_import"

      include CsvRow::SourceImport
      include CsvRow::CompanyImport

      @columns = [:company, :year, :report_type, :source, :title]
      @required = [:company, :year, :report_type, :source]

      def finalize_source_card source_card
        source_card.with_sourcebox do
          source_card.director.catch_up_to_stage :prepare_to_store
        end
      end

      def import
        check_duplication_within_file
        import_company
        import_source
      end
    end
  end
end
