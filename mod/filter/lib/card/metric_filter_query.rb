class Card
  class MetricFilterQuery < Card::FilterQuery
    def wikirate_topic_wql topic
      add_to_wql :right_plus, ["topic", { refer_to: topic }]
    end

    def wikirate_company_wql company
      add_to_wql :right_plus, [company, {}]
    end

    def project_wql project
      add_to_wql :referred_to_by, left: { name: project }, right: "metric"
    end

    def year_wql year
      add_to_wql :right_plus, { type_id: Card::WikirateCompanyID,
                                right_plus: [{ name: year }, {}] }
    end

    def designer_wql designer
      add_to_wql :or, left: designer, right: designer
    end

    def metric_type_wql metric_type
      add_to_wql :right_plus,
                 [Card[:metric_type].name, { refer_to: metric_type }]
    end

    def research_policy_wql research_policy
      add_to_wql :right_plus,
                 [Card[:research_policy].name, { refer_to: research_policy }]
    end
  end
end
