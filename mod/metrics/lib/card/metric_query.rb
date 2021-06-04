class Card
  # query metric lookup table
  class MetricQuery < LookupFilterQuery
    CARD_ID_MAP = {
      designer: :designer_id,
      title: :title_id,
      scorer: :scorer_id,
      research_policy: :policy_id,
      metric_type: :metric_type_id,
      value_type: :value_type_id
    }.freeze

    CARD_ID_FILTERS = ::Set.new(CARD_ID_MAP.keys).freeze
    SIMPLE_FILTERS = ::Set.new(CARD_ID_MAP.values).freeze

    # include MetricFilters

    def lookup_class
      ::Metric
    end

    def lookup_table
      "metrics"
    end

    def card_id_map
      CARD_ID_MAP
    end

    def card_id_filters
      CARD_ID_FILTERS
    end

    def simple_filters
      SIMPLE_FILTERS
    end
  end
end

Metric.const_get("ActiveRecord_Relation")
      .send :include, Card::LookupFilterQuery::ActiveRecordExtension
