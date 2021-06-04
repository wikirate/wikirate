class Card
  class AnswerQuery
    # conditions and condition support methods for non-standard fields.
    module MetricAndCompanyFilters
      include MetricQuery::MetricFilters

      def industry_query value
        multi_company do
          restrict_by_cql :company_id, CompanyFilterQuery.industry_cql(value)
        end
      end

      def company_group_query value
        multi_company do
          group_lists = Array.wrap(value).map { |v| "#{v}+#{:wikirate_company.cardname}" }
          restrict_by_cql :company_id, referred_to_by: group_lists
        end
      end

      def topic_query value
        multi_metric { super }
      end
      alias_method :wikirate_topic_query, :topic_query

      def project_query value
        multi_metric { project_restriction :metric_id, :metric, value }
        multi_company { project_restriction :company_id, :wikirate_company, value }
      end

      def bookmark_query value
        multi_metric { bookmark_restriction :metric_id, value }
        multi_company { bookmark_restriction :company_id, value }
      end

      def company_name_query value
        handle_equals_syntax :company_id, value do
          restrict_by_cql :company_id, name: [:match, value], type_id: WikirateCompanyID
        end
      end

      def country_query value
        @joins << "JOIN answers AS countries ON answers.company_id = countries.company_id"
        @conditions << CompanyFilterQuery.country_condition
        @values << Array.wrap(value)
      end

      def metric_name_query value
        handle_equals_syntax :metric_id, value do
          @joins << :metric
          restrict_by_cql "title_id",
                          name: [:match, value],
                          left_plus: [{}, { type_id: Card::MetricID }]
        end
      end

      def handle_equals_syntax field, value
        return yield unless value.to_s.match?(/^=/)

        filter field, value.card_id
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

      def company_card
        single_company? ? (@company_card ||= Card[@filter_args[:company_id]]) : return
      end

      def metric_card
        single_metric? ? (@metric_card ||= Card[@filter_args[:metric_id]]) : return
      end

      def filter_table field
        if MetricQuery.simple_filters.include?(field.to_sym)
          @joins << :metric
          "metrics"
        else
          "answers"
        end
      end
    end
  end
end
