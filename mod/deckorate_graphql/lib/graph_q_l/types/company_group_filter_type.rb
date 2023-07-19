module GraphQL
  module Types
    class CompanyGroupFilterType < FilterType
      filter_option_values(:metric, "company_group")
    end

  end
end
