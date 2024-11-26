module GraphQL
  module Types
    # Source type for GraphQL
    class Source < DeckorateCard
      field :title, String, null: true
      field :description, String, null: true
      field :report_type, String, null: true
      field :years, [Integer], null: true
      field :original_url, String, null: true
      field :file_url, String, null: true
      lookup_field :metric, Metric, nil, true
      lookup_field :answer, Answer, :answer, true

      # TODO: make companies filterable on sources
      # (see mod/deckorate_research/set/type_plus_right/source/company.rb)

      # cardtype_field :company, Company, :company, true

      def title
        object.card.wikirate_title
      end

      def description
        description = object.card.fetch("description")
        description.content if description.present?
      end

      def years
        object.year_card.item_names.map(&:to_i)
      end

      def original_url
        object.link_url
      end
    end
  end
end
