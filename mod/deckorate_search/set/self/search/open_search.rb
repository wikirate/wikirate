require "opensearch"

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
  puts "OPEN SEARCH QUERY =\n#{os_query}".yellow
  open_search_client.search body: { query: query },
                            index: Cardio.config.open_search_index
end

format do
  def search_with_params
    @search_with_params ||= os_results_to_cards { card.search bool: os_query }
  end

  private

  def os_query
    { minimum_should_match: 1 }.tap do |bool|
      os_term_match { bool }
      os_type_filter { bool }
    end
  end

  def os_results_to_cards
    yield.dig("hits", "hits").map { |result| result["_id"].to_i.card }
  end

  def os_term_match
    return yield unless search_keyword.present?

    yield[:should] = [{ match: { name: search_keyword } },
                      { match_phrase_prefix: { name: search_keyword } }]
  end

  def os_type_filter
    return yield unless type_param.present?

    yield[:filter] = { term: { type_id: type_param.card_id } }
  end
end

format :json do
  def complete_or_match_search *_args
    os_results_to_cards { card.search bool: os_query }.compact.map &:name
  end
end
