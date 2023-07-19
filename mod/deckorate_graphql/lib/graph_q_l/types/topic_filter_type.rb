module GraphQL
  module Types
    class TopicFilterType < FilterType
      filter_option_values(:metric, "wikirate_topic")
    end
  end
end