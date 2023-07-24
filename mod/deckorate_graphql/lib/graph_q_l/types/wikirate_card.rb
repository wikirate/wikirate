module GraphQL
  module Types
    class WikirateCard < Card
      include DeckorateSearch
      class << self
        include DeckorateFields
      end
    end
  end
end