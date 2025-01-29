require "opensearch"
require "colorize"

# Perform Open Search query
# @param parameters [Hash] query hash
# @result [Hash] ruby translation of JSON results
# note: options configured in config/application.rb
# (overrides default Decko method)
def os_search parameters={}
  # puts parameters
  open_search_client.search parameters
end

# is Open Search configured?
def os_search?
  os_options.present?
end

private

# Open Search client object
def open_search_client
  ::OpenSearch::Client.new os_options
end

# note: options configured in config/application.rb
def os_options
  Cardio.config.open_search_options
end

format do
  delegate :os_search?, to: :card

  def os_type_param
    type_param
  end

  # Retrieves results for main search results page
  # Query is based on environmental parameters
  # @return [Array] list of card objects
  # (overrides default Decko method)
  def os_search_returning_cards
    rescuing_open_search [] do
      hits = os_search_with_params.dig "hits", "hits"
      # puts "hits: #{hits}"
      hits.map { |res| os_result_card res }.compact.tap do |cardlist|
        os_ensure_exact_match cardlist
      end
    end
  end

  def os_count_with_params
    rescuing_open_search 0 do
      os_search_with_params.dig "hits", "total", "value"
    end
  end

  def os_search_with_params
    @os_search ||= card.os_search os_search_parameters
  end

  private

  def os_search_parameters
    {
      body: { query: { bool: os_query } },
      from: offset,
      size: limit,
      index: os_search_index
    }
  end

  def os_result_card result
    card = result["_id"]&.to_i&.card
    card if card&.ok? :read
  end

  def rescuing_open_search failure_result
    yield
  rescue Faraday::ConnectionFailed
    Rails.logger.info "OpenSearch connection failed"
    failure_result
  end

  def os_search_index
    Cardio.config.open_search_index
  end

  def os_query
    { minimum_should_match: 1 }.tap do |bool|
      os_type_filter { bool }
      os_term_match { bool }
    end
  end

  # # interprets Open Search results, finding ids and fetching cards with those ids
  # def os_results_to_cards
  #   yield.dig("hits", "hits").map { |result| result["_id"]&.to_i&.card }.compact
  # end

  # constructs the keyword matching "should" clause for the os_query
  def os_term_match
    return unless search_keyword.present?

    yield[:should] = [{ match: { name: search_keyword } },
                      { match_phrase_prefix: { name: search_keyword } }]
  end

  # constructs the type filtering clause for the os_query
  def os_type_filter
    return unless os_type_param.present?

    yield[:filter] = { term: { type_id: os_type_param.card_id } }
  end

  def os_ensure_exact_match cardlist
    exact_match = search_keyword&.card
    return unless os_add_exact_match? cardlist, exact_match

    cardlist.unshift exact_match
  end

  def os_add_exact_match? cardlist, exact_match
    exact_match && !cardlist.include?(exact_match) && os_right_type?(exact_match)
  end

  def os_right_type? exact_match
    return true unless os_type_param.present?

    exact_match.type_code == os_type_param.codename
  end
end
