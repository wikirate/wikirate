module GraphQL
  module Types
    # Data Set type for GraphQL
    class Dataset < WikirateCard

      field :years, [Integer], null: false
      field :description, String, null: false
      cardtype_field :company, Company, :wikirate_company
      lookup_field :metric, Metric
      lookup_field :answer, Answer, :metric_answer

      def years
        object.year_card.item_names.map(&:to_i)
      end
    end
  end
end
