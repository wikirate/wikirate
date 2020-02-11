class Card
  # Filter metrics (e.g. on company pages)
  class MetricFilterQuery < FilterQuery
    include WikirateFilterQuery

    def metric_wql metric
      name_wql metric
    end

    def project_wql project
      add_to_wql :referred_to_by, left: project, right_id: Card::MetricID
    end

    def year_wql year
      return if year == "latest"
      add_to_wql :right_plus, type_id: Card::WikirateCompanyID, right_plus: year
    end

    def designer_wql designer
      add_to_wql :part, designer
    end

    def metric_type_wql metric_type
      add_to_wql :right_plus, [Card::MetricTypeID, { refer_to: metric_type }]
    end

    def research_policy_wql policy
      add_to_wql :right_plus, [Card::ResearchPolicyID, { refer_to: policy }]
    end
  end
end
