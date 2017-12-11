class CSVRow
  module Structure
    require_dependency "csv_row"
    require_dependency "csv_row/company_import"
    require_dependency "csv_row/answer_import"

    # Specifies the structure of a csv row for a csv file that is a file source on
    # wikirate.
    # The difference to {CSVRow::Structure::AnswerCSV} is that the csv file doesn't
    # contain sources, metrics and years.
    # Instead the file itself serves as source for the imported answers
    # and you select in the import form one metric and one year for all answers.
    class AnswerFromSourceCSV < CSVRow
      include CSVRow::CompanyImport
      include CSVRow::AnswerImport

      @columns = [:company, :value]
      @required = :all

      def import
        import_manager.with_conflict_strategy :skip_card do
          import_company
        end
        import_answer
      end
    end
  end
end
