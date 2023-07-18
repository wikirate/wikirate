module GraphQL
  module Types
    class WikirateCard < Card
      class << self
        include WikirateFields
      end
    end
  end
end