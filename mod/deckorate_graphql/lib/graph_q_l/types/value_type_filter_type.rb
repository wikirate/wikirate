module GraphQL
  module Types
    class ValueTypeFilterType < FilterType
      filter_option_values(:metric, "value_type")
    end

  end
end
