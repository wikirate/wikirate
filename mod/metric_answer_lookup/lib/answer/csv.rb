class Answer
  # Methods to format answer for csv output
  module Csv
    def self.included host_class
      host_class.extend ClassMethods
    end

    def csv_line
      CSV.generate_line [answer_id, answer_link, metric_name, company_name, year, value]
    end

    def answer_link
      card_url "~#{answer_id}"
    end

    # class methods for {Answer}
    module ClassMethods
      def csv_title
        CSV.generate_line ["ANSWER ID", "ANSWER_LINK", "METRIC NAME", "COMPANY NAME", "YEAR", "VALUE"]
      end
    end
  end
end
