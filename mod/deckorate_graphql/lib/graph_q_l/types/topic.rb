module GraphQL
  module Types
    # Topic type for GraphQL
    class Topic < Card
      field :metrics, [Metric], null: false
      field :datasets, [Dataset], null: false
      field :description, String, null: false

      def metrics
        referers(:metric, :wikirate_topic).map(&:lookup)
      end

      def datasets
        referers :dataset, :wikirate_topic
      end
    end
  end
end
