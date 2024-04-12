class Card
  class AnswerQuery
    # conditions and condition support methods for non-standard fields.
    module MetricAndCompanyFilters
      include MetricQuery::MetricFilters

      def filter_by_company_group value
        multi_company do
          group_lists = Array.wrap(value).map { |v| [v, :wikirate_company].cardname }
          restrict_by_cql :groups, :company_id, referred_to_by: group_lists
        end
      end

      def filter_by_topic value
        multi_metric { super }
      end
      alias_method :filter_by_wikirate_topic, :filter_by_topic

      def filter_by_dataset value
        multi_metric { dataset_restriction :metric_id, :metric, value }
        multi_company { dataset_restriction :company_id, :wikirate_company, value }
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

      def filter_by_company_name value
        restrict_by_cql :company_name, :company_id,
                        name: [:match, value], type: :wikirate_company
      end

      def filter_by_country value
        filter_by_company_filter :countries, :country_condition, value
      end

      def filter_by_company_category value
        filter_by_company_filter :categories, :category_condition, value
      end

      def filter_by_metric_name value
        @joins << :metric
        restrict_by_cql :title, :title_id,
                        name: [:match, value],
                        left_plus: [{}, { type_id: Card::MetricID }]
      end

      def filter_by_company_filter table, condition_method, value
        company_answer_join table
        @conditions << CompanyFilterCql.send(condition_method)
        @values << Array.wrap(value)
      end

      def company_card
        single_company? ? (@company_card ||= Card[@filter_args[:company_id]]) : return
      end

      def metric_card
        single_metric? ? (@metric_card ||= Card[@filter_args[:metric_id]]) : return
      end

      def filter_by_depender_metric value
        metric = validate_depender_metric value
        return unless (dependees = metric.dependee_metrics).present?
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

      def company_answer_join table
        @joins << "JOIN answers AS #{table} ON answers.company_id = #{table}.company_id"
      end

      # SUPPORT METHODS
      def single_metric?
        @filter_args[:metric_id].is_a? Integer
      end

      def single_company?
        @filter_args[:company_id].is_a? Integer
      end

      def multi_metric
        single_metric? ? return : yield
      end

      def multi_company
        single_company? ? return : yield
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
