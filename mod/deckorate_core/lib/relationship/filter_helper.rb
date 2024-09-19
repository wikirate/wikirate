class Relationship
  # supports filtering by related company groups
  module FilterHelper
    def answer_ids_for metric, company_group
      relationship_prefix = metric.inverse? ? "inverse_" : ""
      company_field = "#{metric&.inverse? ? :subject : :object}_company_id"
      metric_field = "#{relationship_prefix}metric_id"
      company_list_id = company_group&.card&.company_card&.id

      rel = company_group_relation metric, company_field, metric_field, company_list_id
      rel.distinct.pluck :"#{relationship_prefix}answer_id"
    end

    private

    # "relation" in the rails sense
    def company_group_relation metric, company_field, metric_field, company_list_id
      Relationship.joins(
        "join card_references cr on cr.referee_id = relationships.#{company_field}"
      ).where(
        "cr.referer_id = #{company_list_id} and #{metric_field} = #{metric.id}"
      )
    end
  end
end
