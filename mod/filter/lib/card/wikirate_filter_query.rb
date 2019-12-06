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
    # FIXME: support session bookmarks
      method = "#{bookmark_list_id ? '' : 'non'}bookmarker_bookmark_wql"
      send method, value.to_sym
    end

    def nonbookmarker_bookmark_wql value
      return unless value == :bookmark

      add_to_wql :id, -1 # no bookmark results for nonbookmarker
    end

    def bookmarker_bookmark_wql value
      if value == :bookmark
        add_to_wql :linked_to_by, bookmark_list_id
      else
        add_to_wql :not, linked_to_by: bookmark_list_id
      end
    end

    def bookmark_list_id
      return unless Auth.can_bookmark?
      @bookmark_list_id ||= Auth.current.bookmarks_card&.id
    end
  end
end
