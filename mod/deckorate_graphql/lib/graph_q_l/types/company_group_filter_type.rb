module GraphQL
  module Types
    # Company Group FilterType to provide all available company group options
    class CompanyGroupFilterType < FilterType
      filter_option_values(:metric, "company_group")
    end

  end
end
