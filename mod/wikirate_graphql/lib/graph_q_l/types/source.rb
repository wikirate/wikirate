module GraphQL
  module Types
    class Source < Card
      field :title, String, null: true
      field :description, String, null: true
      field :report_type, String, null: true
      field :years, [Integer], null: false

      field :file_url, String, null: true
      field :answers, [Answer], null: false

      # very inefficient!!
      def answers
        ::Card.search(type: :metric_answer,
                      right_plus: [:source, { refer_to: object.id }])&.map &:lookup
      end
    end
  end
end

# type Source implements WikiRateEntity{
#   original_source: String
#   file_url: String
#   year: Int
#   answers: [Answer!]!
#   relationships: [Relationship!]
#   metrics: [Metric!]!
#   report_type: [String!]!
#   companies: [Company!]!
# }
