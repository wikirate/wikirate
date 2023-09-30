module GraphQL
  module Types
    # SortDirEnum enumerates all available options for the sorting direction
    class SortDirEnum < BaseEnum
      value :ascending, value: "asc"
      value :descending, value: "desc"
    end
  end
end
