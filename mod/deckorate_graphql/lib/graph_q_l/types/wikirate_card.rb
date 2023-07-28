module GraphQL
  module Types
    class WikirateCard < Card
      include DeckorateSearch
      extend DeckorateFields
    end
  end
end