class Card
  class MetricQuery
    module AnswerFilters
      def source_query value
        answer_sql = AnswerQuery.new(source: value).lookup_relation.select(:metric_id).to_sql
        @conditions << "metrics.metric_id in (#{answer_sql})"
      end
    end
  end
end
