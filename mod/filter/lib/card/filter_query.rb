class Card
  class FilterQuery
    def topic_wql topic
      add_to_wql :right_plus, [WikirateTopicID, { refer_to: { name: topic } }]
    end
    alias wikirate_topic_wql topic_wql
  end
end
