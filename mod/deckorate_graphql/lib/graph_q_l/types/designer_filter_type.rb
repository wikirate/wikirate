module GraphQL
  module Types
    # Designer FilterType to provide all available designer options
    class DesignerFilterType < FilterType
      filter_option_values(:metric, "designer")
    end
  end
end
