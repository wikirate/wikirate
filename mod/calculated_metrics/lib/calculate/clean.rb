class Calculate
  # handles post-transaction phase of calculation
  module Clean
    def clean
      expire_old_answers
      update_cached_counts
    end

    private

    # EXPIRATION

    def expire_old_answers
      expirables.each { |company_name, year| expire_answer company_name, year }
    end

    def expire_answer company_name, year
      Card::Director.expirees << Card::Name[metric.name, company_name, year.to_s]
    end

    # CACHED COUNTS

    def update_cached_counts
      (metric_cache_count_cards +
        topic_cache_count_cards +
        company_cache_count_cards).each(&:update_cached_count)
    end

    def company_cache_count_cards
      (old_company_ids | unique_company_ids).map do |company_id|
        %i[metric metric_answer wikirate_topic].map { |fld| Card.fetch [company_id, fld] }
      end.flatten
    end

    def metric_cache_count_cards
      %i[metric_answer wikirate_company].map { |fld| Card.fetch [metric.name, fld] }
    end

    def topic_cache_count_cards
      Card::Set::TypePlusRight::WikirateTopic::WikirateCompany
        .company_cache_cards_for_topics metric.wikirate_topic_card&.item_names
    end
  end
end
