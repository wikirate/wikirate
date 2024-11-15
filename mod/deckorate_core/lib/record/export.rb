class Record
  # Methods to format record for csv output
  module Export
    include Card::Env::Location
    include LookupTable::Export

    # Export methods for Record class
    module ClassMethods
      include LookupTable::Export

      def csv_titles detailed=false
        basic = ["Record Page", "Metric", "Company", "Year", "Value", "Source Page"]
        with_detailed basic, detailed do
          ["Record ID", "Original Source", "Source Count", "Comments", "ISIN"]
        end
      end
    end

    def csv_line detailed=false
      basic = [record_link, metric_name, company_name, year, value, source_page_url]
      with_detailed basic, detailed do
        [record_id, source_url, source_count, comments, isin]
      end
    end

    def record_link
      card_url record_id.present? ? "~#{record_id}" : record_name.url_key
    end

    def record_name
      "#{record_log_name}+#{year}".to_name
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
      # prefix id with V (for virtual) if using id from records table
      record_id || "V#{id}"
    end

    def metric_name
      metric_id&.cardname
    end

    def company_name
      company_id&.cardname
    end

    def record_log_name
      "#{metric_name}+#{company_name}"
    end

    def isin
      company_id&.card&.isin_card&.item_names&.join ";"
    end
  end
end
