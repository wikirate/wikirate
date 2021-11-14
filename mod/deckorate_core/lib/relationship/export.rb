class Relationship
  # Methods to format answer for csv output
  module Export
    include Card::Env::Location

    # class methods for {Relationship}
    module ClassMethods
      def csv_title
        CSV.generate_line ["Relationship ID", "Relationship Link", "Answer ID", "Metric",
                           "Subject Company", "Object Company", "Year", "Value"]
      end
    end

    def self.included host_class
      host_class.extend ClassMethods
    end

    def csv_line
      CSV.generate_line [relationship_id, relationship_link, answer_id, metric_name,
                         subject_company_name, object_company_name, year, value]
    end

    def relationship_link
      card_url "~#{relationship_id}"
    end

    def compact_json
      {
        subject_company: subject_company_id,
        object_company: object_company_id,
        metric: metric_id,
        year: year,
        value: value,
        id: relationship_id
      }
    end
  end
end
