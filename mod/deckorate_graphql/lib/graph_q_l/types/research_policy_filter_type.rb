module GraphQL
  module Types
    class ResearchPolicyFilterType < FilterType
      description "Research Policy on a metric can be either CommunityAssessed (anyone can research answers) or DesignerAssessed (only the designer can)"
      filter_option_values(:metric, "research_policy")
    end
  end
end