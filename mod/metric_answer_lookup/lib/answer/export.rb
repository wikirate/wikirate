class Answer
  # Methods to format answer for csv output
  module Export
    include Card::Env::Location

    module ClassMethods
      def csv_title
        CSV.generate_line ["Answer ID", "Answer Link", "Metric", "Company",
                           "Year", "Value", "Source", "Source Count", "Comments"]
      end
    end

    def csv_line
      CSV.generate_line [answer_id,
                         answer_link,
                         metric_name,
                         company_name,
                         year,
                         value,
                         source_url,
                         source_count,
                         comments]
    end

    def answer_link
      card_url answer_id.present? ? "~#{answer_id}" : answer_name.url_key
    end

    def answer_name
      "#{record_name}+#{year}".to_name
    end

    def compact_json
      {
        company: answer.company_id,
        metric: answer.metric_id,
        year: answer.year,
        value: answer.value
      }
    end
    # class methods for {Answer}

    def flex_id
      # prefix id with V (for virtual) if using id from answers table
      answer_id || "V#{id}"
    end
  end
end
