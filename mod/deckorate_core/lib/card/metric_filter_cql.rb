class Card
  # Filter metrics (e.g. on company pages)
  class MetricFilterCql < DeckorateFilterCql
    def name_cql title
      add_to_cql :right, name: [:match, title]
    end

    def metric_cql metric
      name_cql metric
    end

    def dataset_cql dataset
      add_to_cql :referred_to_by, left: dataset, right_id: MetricID
    end

    def year_cql year
      return if year == "latest"
      add_to_cql :right_plus, type_id: CompanyID, right_plus: year
    end

    def designer_cql designer
      add_to_cql :part, designer
    end

    def metric_type_cql metric_type
      add_to_cql :right_plus, refer_to(:metric_type, metric_type)
    end

    def value_type_cql value_type
      add_to_cql :right_plus, refer_to(:value_type, value_type)
    end

    def assessment_cql policy
      add_to_cql :right_plus, refer_to(:assessment, policy)
    end
  end
end
