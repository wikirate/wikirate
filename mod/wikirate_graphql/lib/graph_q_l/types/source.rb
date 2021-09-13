module GraphQL
  module Types
    # Source type for GraphQL
    class Source < Card
      field :title, String, null: true
      field :description, String, null: true
      field :report_type, String, null: true
      field :years, [Integer], null: false

      field :original_url, String, null: true
      field :file_url, String, null: true
      field :answers, [Answer], null: false
      field :relationships, [Relationship], null: false

      def relationships
        referers(:relationship_answer, :source)&.map(&:lookup)
      end

      def answers
        referers(:metric_answer, :source)&.map(&:lookup)
      end

      def original_url
        object.link_url
      end
    end
  end
end

# type Source implements WikiRateEntity{
#   year: Int
#   metrics: [Metric!]!
#   report_type: [String!]!
#   companies: [Company!]!
# }
