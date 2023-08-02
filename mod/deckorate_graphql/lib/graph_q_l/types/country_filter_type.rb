module GraphQL
  module Types
    class CountryFilterType < FilterType
      filter_option_values(:metric, "country")
      end
    end
end
