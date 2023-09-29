module GraphQL
  module Types
    # DeckorateCard extends Card
    class DeckorateCard < Card
      include DeckorateSearch
      extend DeckorateFields
    end
  end
end
