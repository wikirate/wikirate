format do
  def search_keyword
    @search_keyword ||= super || params.dig(:filter, :name)
  end

  def os_term_match
    yield.tap do |bool|
      bool[:minimum_should_match] =  1
      if search_keyword.present?
        bool[:should] = [{ match: { name: search_keyword } },
                         { match_phrase_prefix: { name: search_keyword } }]
      end
    end
  end

  def all_regions
    Card.search type: :region, limit: 0, return: :name, sort: :name
  end

  def os_search_returning_cards
    super.tap do |cardlist|
      ensure_exact_match cardlist
    end
  end

  private

  def ensure_exact_match cardlist
    return unless (exact_match = search_keyword&.card)
    return unless !cardlist.include? exact_match

    if os_type_param.present?
      return unless exact_match.type_code == os_type_param.codename
    end

    cardlist.unshift exact_match
  end
end

format :json do
  def complete_or_match_search limit: nil, start_only: false,
                               additional_cql: {}
    limit ||= Abstract::Search::AUTOCOMPLETE_LIMIT
    return super unless os_search?

    voo.cql.limit = limit
    os_search_returning_cards
  end
end