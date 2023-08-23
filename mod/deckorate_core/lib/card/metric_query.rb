class Card
  # query metric lookup table
  class MetricQuery < LookupQuery
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

    SORT_BY_COUNT = { company: :wikirate_company,
                      answer: :metric_answer,
                      reference: :reference }.freeze

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

    def filter_by_name value
      restrict_by_cql :title, "title_id",
                      name: [:match, value], left_plus: [{}, { type: :metric }]
    end

    def simple_sort_by value
      value == :bookmarkers ? :metric_bookmarkers : value
    end

    def sort_by value
      return super unless (field_id = SORT_BY_COUNT[value]&.card_id)

      @sort_joins <<
        "LEFT JOIN counts ON counts.left_id = metric_id and counts.right_id = #{field_id}"
      "counts.value"
    end

    def sort_by_cardname
      { metric_designer: :designer_id,
        metric_title: :title_id }
    end

    def filter_by_source value
      subsql = AnswerQuery.new(source: value).lookup_relation.select(:metric_id).to_sql
      @conditions << "metrics.metric_id in (#{subsql})"
    end
  end
end

Metric.const_get("ActiveRecord_Relation")
      .send :include, Card::LookupQuery::ActiveRecordExtension
