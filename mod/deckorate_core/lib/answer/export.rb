class Answer
  # Methods to format answer for csv output
  module Export
    include Card::Env::Location
    include LookupTable::Export

    # Export methods for Answer class
    module ClassMethods
      include LookupTable::Export

      def csv_titles detailed=false
        basic = ["Answer Page", "Metric", "Company", "Year", "Value", "Source Page"]
        with_detailed basic, detailed do
          ["Answer ID", "Original Source", "Source Count", "Comments", "ISIN"]
        end
      end
    end

    def csv_line detailed=false
      basic = [answer_link, metric_name, company_name, year, value, source_page_url]
      with_detailed basic, detailed do
        [answer_id, source_url, source_count, comments, isin]
      end
    end

    def answer_link
      card_url answer_id.present? ? "~#{answer_id}" : answer_name.url_key
    end

    def answer_name
      "#{record_name}+#{year}".to_name
    end

    # TODO: store first_source_id as lookup field
    def source_page_url
      card_url first_source_card.id_string if first_source_card
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

    def isin
      company_id&.card&.isin_card&.item_names&.join ";"
    end
  end
end
