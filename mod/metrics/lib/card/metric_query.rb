class Card
  # query metric lookup table
  class MetricQuery < LookupFilterQuery
    self.card_id_map = {
      designer: :designer_id,
      title: :title_id,
      scorer: :scorer_id,
      research_policy: :policy_id,
      metric_type: :metric_type_id,
      value_type: :value_type_id
    }.freeze
    self.card_id_filters = ::Set.new(card_id_map.keys).freeze
    self.simple_filters = ::Set.new(card_id_map.values << :metric_id).freeze

    SORT_BY_COUNT = { company: :wikirate_company, answer: :metric_answer }.freeze

    include MetricFilters

    # whether answer queries with this field should use a metrics table join
    def self.join? field
      field != :metric_id && simple_filters.include?(field)
    end

    def lookup_class
      ::Metric
    end

    def lookup_table
      "metrics"
    end

    def name_query value
      restrict_by_cql "title_id", name: [:match, value],
                                  left_plus: [{}, { type_id: MetricID }]
    end

    def simple_sort_by value
      value == :bookmarkers ? :metric_bookmarkers : value
    end

    def sort_by value
      return super unless (codename = SORT_BY_COUNT[value])

      @sort_joins <<
        "LEFT JOIN counts ON left_id = metric_id and right_id = #{codename.card_id}"
      "counts.value"
    end

    def sort_by_cardname
      { metric_designer: :designer_id,
        metric_title: :title_id }
    end
  end
end

Metric.const_get("ActiveRecord_Relation")
      .send :include, Card::LookupFilterQuery::ActiveRecordExtension
