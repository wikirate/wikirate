class CSVRow
  module Structure
    require_dependency "csv_row"
    require_dependency "csv_row/company_import"
    require_dependency "csv_row/answer_import"

    # Specifies the structure of a csv row for a csv file that is a file source on
    # wikirate.
    # The difference to {CSVRow::Structure::AnswerCSV} is that the csv file doesn't
    # contain sources, metrics andyears.
    # Instead the file itself serves as source for the imported answers
    # and you select in the import form one metric and one year for all answers.
    class AnswerFromSourceCSV < CSVRow
      include CSVRow::CompanyImport
      include CSVRow::AnswerImport

      @columns = [:company, :value]
      @required = :all

      def initialize row, index, import_manager=nil
        # TODO: metric, year and source must be in corrections
        super
      end

      def import
        import_manager.with_conflict_strategy :skip_card do
          import_company
        end
        build_answer_create_args
        # TODO: decide what to do with this duplications check
        #check_for_duplicates
        throw :skip_row, :failed if errors.any?
        import_card answer_create_args
      end
    end
  end
end


