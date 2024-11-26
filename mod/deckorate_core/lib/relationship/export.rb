class Relationship
  # Methods to format answer for csv output
  module Export
    include Card::Env::Location
    include LookupTable::Export

    # class methods for {Relationship}
    module ClassMethods
      include LookupTable::Export
      def csv_titles detailed=false
        basic = ["Relationship Link", "Metric",
                 "Subject Company", "Object Company",
                 "Year", "Value"]
        with_detailed basic, detailed do
          ["Relationship ID", "Answer ID"]
        end
      end
    end

    def self.included host_class
      host_class.extend ClassMethods
    end

    def csv_line detailed=false
      basic = [relationship_link, metric_name,
               subject_company_name, object_company_name,
               year, value]
      with_detailed basic, detailed do
        [relationship_id, answer_id]
      end
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
