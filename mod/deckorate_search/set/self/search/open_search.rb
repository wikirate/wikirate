require "opensearch"
require "colorize"

# Open Search client object
# note: options configured in config/application.rb
def open_search_client
  ::OpenSearch::Client.new Cardio.config.open_search_options
end

# Perform Open Search query
# @param query [Hash] query hash
# @result [Hash] ruby translation of JSON results
# note: options configured in config/application.rb
def search query
  puts "OPEN SEARCH QUERY =\n#{query}".yellow
  open_search_client.search body: query, index: Cardio.config.open_search_index
end

format :json do
  # Retrieves Open Search results for autocompletion in
  # the main search box
  # @return [Array] list of card names
  def complete_or_match_search *_args
    return [] unless search_keyword.present?

    list = card.search(suggestion_query).dig "suggest", "autocomplete"
    return [] unless (options = list&.first&.dig "options")

    options.map { |result| result["_id"]&.to_i&.cardname }
  end
end

format do
  # Retrieves results for main search results page
  # Query is based on environmental parameters
  # @return [Array] list of card objects
  def search_with_params
    @search_with_params ||=
      card.search(query: { bool: os_query }).dig("hits", "hits").map do |result|
        result["_id"]&.to_i&.card
      end
  end

  private

  # Currently this query is shared by autocomplete and the main results.
  # Can separate by assigning different query methods to #search_with_params
  # and #complete_or_match_search
  def os_query
    { minimum_should_match: 1 }.tap do |bool|
      os_term_match { bool }
      os_type_filter { bool }
    end
  end

  # interprets Open Search results, finding ids and fetching cards with those ids
  def os_results_to_cards
    yield.dig("hits", "hits").map { |result| result["_id"]&.to_i&.card }.compact
  end

  # constructs the keyword matching "should" clause for the os_query
  def os_term_match
    return yield unless search_keyword.present?

    yield[:should] = [{ match: { name: search_keyword } },
                      { match_phrase_prefix: { name: search_keyword } }]
  end

  # suggest_query
  def suggestion_query
    { suggest: { autocomplete: { prefix: search_keyword,
                                 completion: { field: "autocomplete_field" } } } }
  end

  # constructs the type filtering clause for the os_query
  def os_type_filter
    return yield unless type_param.present?

    yield[:filter] = { term: { type_id: type_param.card_id } }
  end
end
