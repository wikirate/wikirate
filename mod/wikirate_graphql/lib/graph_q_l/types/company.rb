module GraphQL
  module Types
    # Company type for GraphQL
    class Company < Card
      field :answers, [Answer], "answers to questions about company", null: false
      field :relationships, [Relationship],
            "relationships of which company is either subject or object", null: false
      field :datasets, [Dataset], null: false
      field :logo_url, String, "url for company logo image", null: true

      def answers
        ::Card::AnswerQuery.new({ company_id: object.id }, {}, limit: 10).run
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
