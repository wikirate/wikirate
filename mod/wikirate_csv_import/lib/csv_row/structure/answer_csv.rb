class CsvRow
  module Structure
    # Specifies the structure of a csv row a metric answer import.
    class AnswerCsv < CsvRow
      # include CsvRow::SourceImport
      # include CsvRow::CompanyImport
      # include CsvRow::AnswerImport

      @columns = { metric: { map: true },
                   wikirate_company: { map: true },
                   year: { map: true },
                   value: {},
                   source: { map: true },
                   comment: { optional: true } }

      def card_args
        return {} unless (metric_card = Card[metric])
        r = @row.clone
        r[:company] = r.delete :wikirate_company
        metric_card.create_answer_args r.merge(ok_to_exist: true)
      end
    end
  end
end
