class Relationship
  # Methods to format answer for csv output
  module Csv
    include Card::Env::Location

    def self.included host_class
      host_class.extend ClassMethods
    end

    def csv_line
      CSV.generate_line [relationship_id, answer_link, answer_id,  metric_name,
                         subject_company_name, object_company_name, year, value]
    end

    def answer_link
      card_url "~#{relationship_id}"
    end

    # class methods for {Answer}
    module ClassMethods
      def csv_title
        CSV.generate_line ["RELATIONSHIP ID", "RELATIONSHIP_LINK", "ANSWER ID",
                           "METRIC NAME", "SUBJECT COMPANY NAME", "OBJECT_COMPANY NAME",
                           "YEAR", "VALUE"]
      end
    end
  end
end
