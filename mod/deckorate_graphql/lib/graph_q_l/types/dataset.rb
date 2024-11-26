module GraphQL
  module Types
    # Dataset type for GraphQL
    class Dataset < DeckorateCard
      field :years, [Integer], null: false
      field :description, String, null: false
      cardtype_field :company, Company, :company, true
      lookup_field :metric, Metric, nil, true
      lookup_field :answer, Answer, :answer, true
      def years
        object.year_card.item_names.map(&:to_i)
      end
    end
  end
end
