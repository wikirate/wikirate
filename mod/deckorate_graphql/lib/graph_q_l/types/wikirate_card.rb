module GraphQL
  module Types
    # WikirateCard extends Card
    class WikirateCard < Card
      include DeckorateSearch
      extend DeckorateFields
    end
  end
end
