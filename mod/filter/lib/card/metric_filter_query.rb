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
      add_to_wql :right_plus, refer_to(:metric_type, metric_type)
    end

    def value_type_wql value_type
      add_to_wql :right_plus, refer_to(:value_type, value_type)
    end

    def research_policy_wql policy
      add_to_wql :right_plus, refer_to(:research_policy, policy)
    end

    def refer_to codename, value
      value = value.is_a?(Array) ? value.unshift(:in) : value
      [Codename.id(codename), { refer_to: value }]
    end
  end
end
