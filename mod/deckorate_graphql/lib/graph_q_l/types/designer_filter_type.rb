module GraphQL
  module Types
    class DesignerFilterType < FilterType
      filter_option_values(:metric, "designer")
    end
  end
end