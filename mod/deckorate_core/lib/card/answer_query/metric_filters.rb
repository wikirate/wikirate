class Card
  class AnswerQuery
    # conditions and condition support methods for metric-related fields.
    module MetricFilters
      include MetricQuery::MetricFilters

      def filter_by_topic value
        multi_metric { super }
      end

      def filter_by_dataset value
        multi_metric { dataset_restriction :metric_id, :metric, value }
        multi_company { dataset_restriction :company_id, :company, value }
        dataset_year_restriction value
      end

      # EXPERIMENTAL. no public usage
      def filter_by_dataset_metric value
        dataset_restriction :metric_id, :metric, value
      end

      def filter_by_bookmark value
        field = single_metric? ? :company_id : :metric_id
        bookmark_restriction field, value
      end

      def filter_by_metric_keyword value
        @joins << :metric
        restrict_by_cql :title, :title_id,
                        name: [:match, value],
                        left_plus: [{}, { type: :metric }]
      end

      def metric_card
        single_metric? ? (@metric_card ||= Card[@filter_args[:metric_id]]) : return
      end

      def filter_by_depender_metric value
        metric = validate_depender_metric value
        return @empty_result = true unless (dependees = metric.dependee_metrics).present?
        filter :metric_id, dependees.map(&:id)
        company_answer_join :dependee
        @conditions <<
          "dependee.metric_id = #{metric.id} and dependee.year = answers.year"
      end

      private

      def validate_depender_metric value
        metric = value.card
        return metric if metric&.calculated?

        raise Error::UserError, "not a calculated metric: #{value}"
      end

      # SUPPORT METHODS
      def single_metric?
        @filter_args[:metric_id].is_a? Integer
      end

      def multi_metric
        single_metric? ? return : yield
      end

      def filter_table field
        if MetricQuery.join? field.to_sym
          @joins << :metric
          "metrics"
        else
          lookup_table
        end
      end
    end
  end
end
