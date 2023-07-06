module GraphQL
  module Types
    # Company type for GraphQL
    class Company < Card
      subcardtype_field :answer, Answer, :metric_answer
      field :relationships, [Relationship],
            "relationships of which company is either subject or object", null: false
      field :datasets, [Dataset], null: false
      field :logo_url, String, "url for company logo image", null: true

      def answers metric_id: nil, limit: Card.default_limit, offset: Card.default_offset, **filter
        filter[:company_id] = object.card_id
        filter[:metric_id] = metric_id if metric_id
        ::Card::AnswerQuery.new(filter, {}, limit: limit, offset: offset).lookup_relation.all
      end

      def relationships
        ::Relationship.where(
          "subject_company_id = #{object.id} OR object_company_id = #{object.id}"
        ).limit(10).all
      end

      def datasets
        referers :dataset, :wikirate_company
      end

      def logo_url
        img = object.image_card
        img.format(:text).render_source if img.real?
      end
    end
  end
end
