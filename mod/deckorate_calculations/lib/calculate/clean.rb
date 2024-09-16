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
      Card.expire answer_name
      Card.expire answer_name.field(:value)
    end

    # CACHED COUNTS

    def update_cached_counts
      update_metric_cache_count_cards
      update_company_cache_count_cards
    end

    def update_company_cache_count_cards
      new_company_ids = unique_company_ids
      update_and_flag_company_counts old_company_ids, "-"
      update_and_flag_company_counts new_company_ids, "-"
      add_missing_counts new_company_ids
    end

    def add_missing_counts new_company_ids
      company_field_ids.each do |field_id|
        new_company_ids.each_slice(1000) do |slice|
          exist = Card.count.where(left_id: slice, right_id: field_id).pluck :left_id
          missing = slice - exist
          new_counts = missing.map do |company_id|
            { left_id: company_id, right_id: field_id, value: 1, flag: true }
          end
          Card::Count.insert_all new_counts
        end
      end
    end

    # This is a fast but flawed update that leaves numbers incorrect whenever
    def update_and_flag_company_counts list, operator
      list.each_slice(5000) do |slice|
        Card::Count.where(left_id: slice, right_id: company_field_ids)
                   .update_all "value = value #{operator} 1, flag = true"
      end
    end

    def company_field_ids
      @company_field_ids ||= %i[metric metric_answer].map &:card_id
    end

    def update_metric_cache_count_cards
      %i[metric_answer wikirate_company].each do |fld|
        Card.fetch([metric.name, fld]).update_cached_count_when_ready
      end
    end

    # def topic_cache_count_cards
    #   Card::Set::TypePlusRight::Topic::WikirateCompany
    #     .company_cache_cards_for_topics metric.topic_card&.item_names
    # end
  end
end
