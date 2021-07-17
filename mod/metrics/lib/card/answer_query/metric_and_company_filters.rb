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

      # EXPERIMENTAL. no public usage
      def project_metric_query value
        project_restriction :metric_id, :metric, value
      end

      def bookmark_query value
        multi_metric { bookmark_restriction :metric_id, value }
        multi_company { bookmark_restriction :company_id, value }
      end

      def company_name_query value
        restrict_by_cql :company_id, name: [:match, value], type_id: WikirateCompanyID
      end

      def country_query value
        @joins << "JOIN answers AS countries ON answers.company_id = countries.company_id"
        @conditions << CompanyFilterQuery.country_condition
        @values << Array.wrap(value)
      end

      def metric_name_query value
        @joins << :metric
        restrict_by_cql "title_id",
                        name: [:match, value],
                        left_plus: [{}, { type_id: Card::MetricID }]
      end

      # EXPERIMENTAL. used by fashionchecker but otherwise not public
      #
      # This is ultimately a company restriction, limiting the answers to the
      # companies related to another by a given relationship metric
      #
      # will also need to support year and value constraints
      def relationship_query value
        metric_id = value[:metric_id]&.to_i
        return unless (metric_card = metric_id&.card)

        @joins << "JOIN relationships AS r " \
                  "ON answers.company_id = r.#{metric_card.inverse_company_id_field}"
        @conditions << "r.metric_id = ? AND #{metric_card.company_id_field} = ?"
        @values += [metric_id, value[:company_id]]
      end

      # EXPERIMENTAL. used by fashionchecker but otherwise not public
      #
      # This is ultimately a company restriction, limiting the answers to the
      # companies with an answer for another metric.
      #
      # will also need to support year and value constraints
      def answer_query value
        return unless (metric_id = value[:metric_id]&.to_i)

        @joins << "JOIN answers AS a2 ON answers.company_id = a2.company_id"
        @conditions << "a2.metric_id = ?"
        @values << metric_id
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
