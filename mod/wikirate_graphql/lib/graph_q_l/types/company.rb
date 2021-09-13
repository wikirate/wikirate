module GraphQL
  module Types
    # Company type for GraphQL
    class Company < Card
      field :logo_url, String, "url for company logo image", null: true
      field :answers, [Answer], "answers to questions about company", null: false
      field :relationships, [Relationship],
            "relationships of which company is either subject or object", null: false

      def logo_url
        img = object.image_card
        img.format(:text).render_source if img.real?
      end

      def answers
        ::Answer.where(company_id: object.id).limit(10).all
      end

      def relationships
        ::Relationship.where(
          "subject_company_id = #{object.id} OR object_company_id = #{object.id}"
        ).limit(10).all
      end
    end
  end
end
