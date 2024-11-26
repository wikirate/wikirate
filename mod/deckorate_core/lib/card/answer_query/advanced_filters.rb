class Card
  class AnswerQuery
    # conditions and condition support methods for non-standard fields.
    module AdvancedFilters
      # filter for companies with answers that meet the criteria
      # @param value [Hash (or Array of Hashes)] each hash represents one constraint.
      #   companies much match all constraints.
      # @option value [Integer] metric_id
      # @option value [String] year
      # @option value [Cardish] related_company_group
      # @option value [String, Hash] value
      def filter_by_company_answer value
        Array.wrap(value).each_with_index do |constraint, index|
          table = "co_ans#{index}"
          @joins += company_answer_join(table)
          @conditions << CompanyFilterCql.company_answer_condition(table, constraint)
        end
      end

      # filter for companies related to the group set in this value
      def filter_by_related_company_group company_group
        return unless single_metric?

        restrict_to_ids :answer_id,
                        Relationship.answer_ids_for(metric_card, company_group)
      end

      # # TODO: delete the following after confirming fashionchecker works without it
      #
      # def filter_by_answer value
      #   return unless (metric_id = value[:metric_id]&.to_i)
      #   exists = "SELECT * from answers AS a2 " \
      #     "WHERE answers.company_id = a2.company_id " \
      #     "AND a2.metric_id = ?"
      #   @conditions << "EXISTS (#{exists})"
      #   @values << metric_id
      # end

      # EXPERIMENTAL. used by fashionchecker but otherwise not public
      # TODO: extend company_answer api to include this
      #
      # This is ultimately a company restriction, limiting the answers to the
      # companies related to another by a given relation metric
      #
      # will also need to support year and value constraints
      #
      # filter for companies related to a given company by a given metric
      # @param value [Hash]
      # @option value [Integer] metric_id (REQUIRED)
      # @option value [Integer] company_id
      def filter_by_relationship value
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
