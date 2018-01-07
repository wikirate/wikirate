class Answer
  module Csv
    def self.csv_title
      CSV.generate_line ["ANSWER ID", "METRIC NAME", "COMPANY NAME", "YEAR", "VALUE"]
    end

    def csv_line
      CSV.generate_line [answer_id, metric_name, company_name, year, value]
    end
  end
end
