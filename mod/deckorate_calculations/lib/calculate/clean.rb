class Calculate
  # handles post-transaction phase of calculation
  module Clean
    def clean
      expire_old_answers
      refresh_metric_counts
      flag_company_counts
    end

    private

    # EXPIRATION

    def expire_old_answers
      expirables.each { |company_name, year| expire_answer company_name, year }
    end

    def expire_answer company_name, year
      answer_name = Card::Name[metric.name, company_name, year.to_s]
      Card.expire answer_name
      Card.expire answer_name.field(:value)
    end

    # CACHED COUNTS

    def refresh_metric_counts
      %i[metric_answer wikirate_company].each do |fld|
        Card.fetch([metric.name, fld]).refresh_cached_count
      end
    end

    def flag_company_counts
      field_ids = %i[metric metric_answer].map(&:card_id)
      Card::Count.flag_all old_company_ids, field_ids, increment: -1
      Card::Count.flag_all unique_company_ids, field_ids, increment: 1
    end

    # def topic_cache_count_cards
    #   Card::Set::TypePlusRight::Topic::WikirateCompany
    #     .company_cache_cards_for_topics metric.topic_card&.item_names
    # end
  end
end
