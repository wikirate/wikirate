class Card
  class AnswerQuery
    # filters based on related companies
    module RelationshipFilters
      def related_company_group_query company_group
        restrict_to_ids :answer_id,
                        Relationship.answer_ids_for(metric_card, company_group)
      end
    end
  end
end
