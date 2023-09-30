module GraphQL
  module Types
    # SortByEnum enumerates all available options when sorting cards
    class SortByEnum < BaseEnum
      value :name, value: "name"
      value :created_at, value: "create"
      value :updated_at, value: "update"
    end
  end
end
