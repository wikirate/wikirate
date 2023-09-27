module GraphQL
  module Types
    # Wikirate topic FilterType to provide all available topics options
    class WikirateTopicFilterType < FilterType
      filter_option_values(:metric, "wikirate_topic")
    end
  end
end
