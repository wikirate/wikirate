module GraphQL
  module Types
    # Source type for GraphQL
    class Source < WikirateCard
      field :title, String, null: true
      field :description, String, null: true
      field :report_type, String, null: true
      field :years, [Integer], null: true

      field :original_url, String, null: true
      field :file_url, String, null: true
      lookup_field :metric, Metric
      lookup_field :answer, Answer, :metric_answer
      cardtype_field :company, Company, :wikirate_company

      field :relationships, [Relationship], null: false

      def title
        object.card.wikirate_title
      end

      def description
        description = object.card.fetch("description")
        description.content if description.present?
      end

      def relationships
        referers(:relationship_answer, :source)&.map(&:lookup)
      end

      def original_url
        object.link_url
      end
    end
  end
end
