class Card
  # Filter metrics (e.g. on company pages)
  class MetricFilterQuery < FilterQuery
    include WikirateFilterQuery

    def metric_wql metric
      name_wql metric
    end

    def project_wql project
      add_to_wql :referred_to_by, left: project, right_id: MetricID
    end

    def year_wql year
      return if year == "latest"
      add_to_wql :right_plus, type_id: WikirateCompanyID, right_plus: year
    end

    def designer_wql designer
      add_to_wql :part, designer
    end

    def metric_type_wql metric_type
      add_to_wql :right_plus, [MetricTypeID, { refer_to: metric_type }]
    end

    def research_policy_wql policy
      add_to_wql :right_plus, [ResearchPolicyID, { refer_to: policy }]
    end

    def bookmark_wql value
      return {} unless Auth.signed_in? # FIXME: use session bookmarks

      bookmarked = { linked_to_by: Card::Name[Auth.current.name, :bookmarks] }
      value == :nobookmark ? { not: bookmarked } : bookmarked
    end
  end
end
