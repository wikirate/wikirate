module GraphQL
  module Types
    # Company type for GraphQL
    class Company < DeckorateCard
      field :headquarters, String, null: true
      field :wikipedia, String, null: true
      field :open_corporates, String, null: true
      field :sec_cik, String, null: true
      field :os_id, String, null: true
      lookup_field :answer, Answer, :metric_answer, true
      field :relationships, [Relationship],
            "relationships of which company is either subject or object", null: true
      field :datasets, [Dataset], null: false
      field :logo_url, String, "url for company logo image", null: true

      def os_id
        object.card.oar_id
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
