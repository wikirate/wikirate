class Card
  class AnswerQuery
    # filters based on related companies
    module RelationshipFilters
      def related_company_group_query value
        company_id_field = "#{metric_card&.inverse? ? :subject : :object}_company_id"
        company_pointer_id = Card[value]&.wikirate_company_card&.id
        answer_ids = answer_ids_from_relationships company_id_field, company_pointer_id
        restrict_to_ids :answer_id, answer_ids
      end

      private

      def answer_ids_from_relationships company_id_field, referer_id
        answer_id_field = :"#{relationship_prefix}answer_id"
        relationship_relation(company_id_field, referer_id).distinct.pluck answer_id_field
      end

      # "relationship" in the wikirate sense. "relation" in the rails sense
      def relationship_relation company_id_field, referer_id
        Relationship.joins(
          "join card_references cr on cr.referee_id = relationships.#{company_id_field}"
        ).where(
          "cr.referer_id = #{referer_id} " \
          "and #{relationship_prefix}metric_id = #{metric_card.id}"
        )
      end

      def relationship_prefix
        @relationship_prefix ||= metric_card&.inverse? ? "inverse_" : ""
      end
    end
  end
end
