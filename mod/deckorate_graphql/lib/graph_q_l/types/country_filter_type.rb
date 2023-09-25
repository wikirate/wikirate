module GraphQL
  module Types
    # Country FilterType to provide all available country options
    class CountryFilterType < FilterType
      filter_option_values(:metric, "country")
    end
  end
end
