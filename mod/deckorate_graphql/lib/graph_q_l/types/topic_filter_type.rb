module GraphQL
  module Types
    # Wikirate topic FilterType to provide all available topics options
    class TopicFilterType < FilterType
      filter_option_values :metric, "topic"
    end
  end
end
