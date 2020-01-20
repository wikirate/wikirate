class Card
  # method shared in many queries.
  module WikirateFilterQuery
    def topic_wql topic
      add_to_wql :right_plus, [WikirateTopicID, { refer_to: topic }]
    end
    alias wikirate_topic_wql topic_wql

    # @param value [Symbol] :bookmark or :nobookmark
    # @return wql to find cards that the signed in user has (or has not) bookmarked
    def bookmark_wql value
      return unless (restriction = Bookmark.id_restriction(value.to_sym == :bookmark))

      restriction = -1 if restriction.blank? # empty array
      # need a way to force wql to return empty result without query

      add_to_wql :id, restriction
    end
  end
end
