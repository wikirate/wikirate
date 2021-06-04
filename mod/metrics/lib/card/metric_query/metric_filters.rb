class Card
  class MetricQuery
    # metric-related filters (also used by AnswerQuery)
    module MetricFilters
      def topic_query value
        restrict_by_cql(
          :metric_id,
          right_plus: [:wikirate_topic, { refer_to: (["in"] + Array.wrap(value)) } ]
        )
      end
      alias_method :wikirate_topic_query, :topic_query
    end
  end
end
