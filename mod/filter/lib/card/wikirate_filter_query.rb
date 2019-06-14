class Card
  # method shared in many queries.
  module WikirateFilterQuery
    def topic_wql topic
      add_to_wql :right_plus, [WikirateTopicID, { refer_to: topic }]
    end
    alias wikirate_topic_wql topic_wql
  end
end
