class Card
  # method shared in many queries.
  class WikirateFilterCql < FilterCql
    def topic_cql topic
      topic = [:in] + Array.wrap(topic)
      add_to_cql :right_plus, [:wikirate_topic, { refer_to: topic }]
    end
    alias wikirate_topic_cql topic_cql

    # @param value [Symbol] :bookmark or :nobookmark
    # @return cql to find cards that the signed in user has (or has not) bookmarked
    def bookmark_cql value
      Card::Bookmark.id_restriction(value.to_sym == :bookmark) do |restriction|
        restriction = -1 if restriction.blank? # empty array
        # need a way to force cql to return empty result without query
        add_to_cql :id, restriction
      end
    end
  end
end
