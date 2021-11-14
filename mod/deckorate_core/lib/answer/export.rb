class Answer
  # Methods to format answer for csv output
  module Export
    include Card::Env::Location

    # Export methods for Answer class
    module ClassMethods
      def csv_title
        CSV.generate_line ["Answer ID", "Answer Page",
                           "Metric", "Company", "Year", "Value",
                           "Source Page", "Original Source", "Source Count",
                           "Comments"]
      end
    end

    def csv_line
      CSV.generate_line [answer_id,
                         answer_link,
                         metric_name,
                         company_name,
                         year,
                         value,
                         source_page_url,
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

    # TODO: store first_source_id as lookup field
    def source_page_url
      card_url "~#{first_source_card.id}" if first_source_card
    end

    def compact_json
      {
        company: company_id,
        metric: metric_id,
        year: year,
        value: value,
        id: flex_id,
        comment: comments
      }
    end

    def flex_id
      # prefix id with V (for virtual) if using id from answers table
      answer_id || "V#{id}"
    end

    def metric_name
      metric_id&.cardname
    end

    def company_name
      company_id&.cardname
    end

    def record_name
      "#{metric_name}+#{company_name}"
    end
  end
end
