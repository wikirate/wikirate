module GraphQL
  module Types
    class WikirateTopicFilterType < FilterType
      filter_option_values(:metric, "wikirate_topic")
    end
  end
end