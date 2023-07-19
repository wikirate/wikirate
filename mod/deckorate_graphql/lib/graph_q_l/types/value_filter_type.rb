module GraphQL
  module Types
    class ValueFilterType < FilterType
      filter_option_values(:metric, "value_type")
    end

  end
end
