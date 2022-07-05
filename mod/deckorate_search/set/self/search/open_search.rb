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
# (overrides default Decko method)
def search parameters={}
  # puts "OPEN SEARCH PARAMS =\n#{parameters}".yellow
  parameters[:index] = Cardio.config.open_search_index
  open_search_client.search parameters
end

format :json do
  # Retrieves Open Search results for autocompletion in
  # the main search box
  # @return [Array] list of card names
  # (overrides default Decko method)
  def complete_or_match_search *_args
    return [] unless search_keyword.present? && (options = autocomplete_options)

    options.map { |result| result["_id"]&.to_i&.cardname }
  end

  private

  def autocomplete_options
    card.search(body: { suggest: suggestion_query })
      &.dig("suggest", "autocomplete")
      &.first&.dig "options"
  end
end

format do
  # Retrieves results for main search results page
  # Query is based on environmental parameters
  # @return [Array] list of card objects
  # (overrides default Decko method)
  def search_with_params
    os_search.dig("hits", "hits").map do |result|
      result["_id"]&.to_i&.card
    end
  end

  # @return [Integer]
  # (overrides default Decko method)
  def count_with_params
    os_search.dig "hits", "total", "value"
  end

  private

  def os_search
    @os_search ||= card.search body: { query: { bool: os_query } },
                               from: offset,
                               size: limit
  end

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
    return unless search_keyword.present?

    yield[:should] = [{ match: { name: search_keyword } },
                      { match_phrase_prefix: { name: search_keyword } }]
  end

  # constructs the type filtering clause for the os_query
  def os_type_filter
    return unless type_param.present?

    yield[:filter] = { term: { type_id: type_param.card_id } }
  end

  # suggest_query
  def suggestion_query
    { autocomplete: { prefix: search_keyword,
                      completion: { field: "autocomplete_field",
                                    contexts: { type_id: suggest_contexts } } } }
  end

  # constructs the context filtering clause for the suggest_query
  # in case of multiple contexts we are favoring other contexts than source
  def suggest_contexts
    filter_type_ids.map do |type_id|
      { context: type_id, boost: (type_id == :source.card_id ? 1 : 2) }
    end
  end
end
