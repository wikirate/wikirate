class Card
  class AnswerQuery
    # conditions and condition support methods for non-standard fields.
    module MetricAndCompanyFilters
      include MetricQuery::MetricFilters

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
        multi_metric { bookmark_restriction :metric_id, value }
        multi_company { bookmark_restriction :company_id, value }
      end

      def company_name_query value
        restrict_by_cql :company_id, name: [:match, value], type_id: WikirateCompanyID
      end

      def country_query value
        company_filter_query "countries", :country_condition, value
      end

      def company_category_query value
        company_filter_query "categories", :company_category_condition, value
      end

      # TODO: refactor this away / use answer_query
      def company_filter_query table, condition_method, value
        @joins << "JOIN answers AS #{table} ON answers.company_id = #{table}.company_id"
        @conditions << CompanyFilterQuery.send(condition_method)
        @values << Array.wrap(value)
      end

      def metric_name_query value
        @joins << :metric
        restrict_by_cql "title_id",
                        name: [:match, value],
                        left_plus: [{}, { type_id: Card::MetricID }]
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
        if MetricQuery.join? field.to_sym
          @joins << :metric
          "metrics"
        else
          "answers"
        end
      end

      # EXPERIMENTAL. used by fashionchecker but otherwise not public
      #
      # This is ultimately a company restriction, limiting the answers to the
      # companies related to another by a given relationship metric
      #
      # will also need to support year and value constraints
      def relationship_query value
        metric_id = value[:metric_id]&.to_i
        company_id = value[:company_id]
        return unless (m = metric_id&.card)

        exists = "SELECT * FROM relationships AS r " \
          "WHERE answers.company_id = r.#{m.company_id_field} " \
          "AND r.#{m.metric_lookup_field} = ?"

        @values << metric_id
        if company_id.present?
          exists << " AND #{m.inverse_company_id_field} = ?"
          @values << company_id
        end
        @conditions << "EXISTS (#{exists})"
      end

      # EXPERIMENTAL. used by fashionchecker but otherwise not public
      #
      # This is ultimately a company restriction, limiting the answers to the
      # companies with an answer for another metric.
      #
      # will also need to support year and value constraints
      def answer_query value
        return unless (metric_id = value[:metric_id]&.to_i)
        exists = "SELECT * from answers AS a2 WHERE answers.company_id = a2.company_id " \
          "AND a2.metric_id = ?"
        @conditions << "EXISTS (#{exists})"
        @values << metric_id
      end
    end
  end
end
