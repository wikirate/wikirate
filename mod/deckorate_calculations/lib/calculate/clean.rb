class Calculate
  # handles post-transaction phase of calculation
  module Clean
    def clean
      expire_old_records
      refresh_metric_counts
      flag_company_counts
    end

    private

    # EXPIRATION

    def expire_old_records
      expirables.each { |company_name, year| expire_record company_name, year }
    end

    def expire_record company_name, year
      record_name = Card::Name[metric.name, company_name, year.to_s]
      Card.expire record_name
      Card.expire record_name.field(:value)
    end

    # CACHED COUNTS

    def refresh_metric_counts
      %i[record company].each do |fld|
        Card.fetch([metric.name, fld]).refresh_cached_count
      end
    end

    def flag_company_counts
      field_ids = %i[metric record].map(&:card_id)
      Card::Count.flag_all old_company_ids, field_ids, increment: -1
      Card::Count.flag_all unique_company_ids, field_ids, increment: 1
    end
  end
end
