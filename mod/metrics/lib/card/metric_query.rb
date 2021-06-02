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

    CARD_ID_FILTERS = ::Set.new(CARD_ID_MAP.values)

    # include MetricFilters

    def lookup_class
      ::Metric
    end

    def lookup_table
      "metrics"
    end
  end
end


module ::LookupTable
  module ActiveRecordExtension
    # @params hash [Hash] key1: dir1, key2: dir2
    def sort hash
      hash.present? ? sort_by_hash(hash) : self
    end

    def paging args
      return self unless valid_page_args? args
      limit(args[:limit]).offset(args[:offset])
    end

    def valid_page_args? args
      args.present? && args[:limit].to_i.positive?
    end
  end
  ::Metric.const_get("ActiveRecord_Relation").send :include, ActiveRecordExtension
end
