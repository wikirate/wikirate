module GraphQL
  module Types
    # Assessment FilterType to provide all available assessment options
    class AssessmentFilterType < FilterType
      description "Assessment on a metric can be either
      CommunityAssessed (anyone can research answers) or DesignerAssessed
      (only the designer can)"
      filter_option_values(:metric, "assessment")
    end
  end
end
