format do
  def search_keyword
    @search_keyword ||= super || params.dig(:filter, :name)
  end

  def all_regions
    Card.search type: :region, limit: 0, return: :name, sort: :name
  end
end

format :json do
  def complete_or_match_search limit: nil, start_only: false,
                               additional_cql: {}
    limit ||= Abstract::Search::AUTOCOMPLETE_LIMIT
    return super unless os_search?

    voo.cql = { limit: limit }
    os_search_returning_cards
  end
end
