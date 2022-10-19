class Card
  class AnswerQuery
    # conditions and condition support methods for non-standard fields.
    module MetricAndCompanyFilters
      include MetricQuery::MetricFilters

      def company_group_query value
        multi_company do
          group_lists = Array.wrap(value).map { |v| [v, :wikirate_company].cardname }
          restrict_by_cql :groups, :company_id, referred_to_by: group_lists
        end
      end

      def topic_query value
        multi_metric { super }
      end
      alias_method :wikirate_topic_query, :topic_query

      def dataset_query value
        multi_metric { dataset_restriction :metric_id, :metric, value }
        multi_company { dataset_restriction :company_id, :wikirate_company, value }
        dataset_year_restriction value
      end

      # EXPERIMENTAL. no public usage
      def dataset_metric_query value
        dataset_restriction :metric_id, :metric, value
      end

      def bookmark_query value
        field = single_metric? ? :company_id : :metric_id
        bookmark_restriction field, value
      end

      def company_name_query value
        restrict_by_cql :company_name, :company_id,
                        name: [:match, value], type: :wikirate_company
      end

      def country_query value
        company_filter_query :countries, :country_condition, value
      end

      def company_category_query value
        company_filter_query :categories, :category_condition, value
      end

      def metric_name_query value
        @joins << :metric
        restrict_by_cql :title, :title_id,
                        name: [:match, value],
                        left_plus: [{}, { type_id: Card::MetricID }]
      end

      def company_filter_query table, condition_method, value
        company_answer_join table
        @conditions << CompanyFilterQuery.send(condition_method)
        @values << Array.wrap(value)
      end

      def company_card
        single_company? ? (@company_card ||= Card[@filter_args[:company_id]]) : return
      end

      def metric_card
        single_metric? ? (@metric_card ||= Card[@filter_args[:metric_id]]) : return
      end

      private

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
          "answers"
        end
      end
    end
  end
end
