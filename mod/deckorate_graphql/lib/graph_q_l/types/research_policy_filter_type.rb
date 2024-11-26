module GraphQL
  module Types
    # Research policy FilterType to provide all available research policy options
    class ResearchPolicyFilterType < FilterType
      description "Research Policy on a metric can be either
      CommunityAssessed (anyone can research answer) or DesignerAssessed
      (only the designer can)"
      filter_option_values(:metric, "research_policy")
    end
  end
end
