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
      answer_name = Card::Name[metric.name, company_name, year.to_s]
      Card::Director.expirees << answer_name
      Card::Director.expirees << answer_name.field(:value)
    end

    # CACHED COUNTS

    def update_cached_counts
      update_metric_cache_count_cards
      update_company_cache_count_cards
    end

    def update_company_cache_count_cards
      (old_company_ids | unique_company_ids).each do |company_id|
        %i[metric metric_answer].each do |fld|
          update_cached_count company_id, fld
        end
      end
    end

    def update_metric_cache_count_cards
      %i[metric_answer wikirate_company].each do |fld|
        update_cached_count metric.name, fld
      end
    end

    def update_cached_count left, right
      Card.fetch([left, right]).update_cached_count_when_ready
    end

    # def topic_cache_count_cards
    #   Card::Set::TypePlusRight::Topic::WikirateCompany
    #     .company_cache_cards_for_topics metric.topic_card&.item_names
    # end
  end
end
