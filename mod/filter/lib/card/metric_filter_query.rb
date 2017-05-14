class Card
  class MetricFilterQuery < Card::FilterQuery
    def wikirate_topic_wql topic
      add_to_wql :right_plus, [WikirateTopicID, { refer_to: topic }]
    end

    def wikirate_company_wql company
      add_to_wql :right_plus, company
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

    def research_policy_wql research_policy
      add_to_wql :right_plus, [ResearchPolicyID, { refer_to: research_policy }]
    end
  end
end
