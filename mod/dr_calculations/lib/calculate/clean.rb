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

    # TODO: optimize
    # by looking for opportunities not to update cached counts, eg:
    # when a company's answers are merely updated (not added or removed),
    # the company has same number of answers and metrics before and after the calculation,
    # so there is no need to recount
    #
    # have not yet confirmed with benchmarking, but it appears that these cached count
    # updates are the slowest remaining part of the calculation process
    #
    # we could also consider some sort of bulk querying/counting/updating mechanism,
    # but that's a heavier lift than just avoiding counts that don't need to be made.

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
