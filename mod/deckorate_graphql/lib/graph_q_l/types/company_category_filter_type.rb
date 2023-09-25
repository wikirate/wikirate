module GraphQL
  module Types
    # Company category FilterType to provide all available company categories options
    class CompanyCategoryFilterType < FilterType
      filter_option_values(:metric, "company_category")
    end
  end
end
