class Card
  class AnswerQuery
    # conditions and condition support methods for non-standard fields.
    module AdvancedFilters
      def company_answer_query value
        Array.wrap(value).each_with_index do |constraint, index|
          table = "co_ans#{index}"
          joins << company_answer_join(table)
          @conditions << CompanyFilterQuery.company_answer_condition(table, constraint)
        end
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
    end
  end
end
