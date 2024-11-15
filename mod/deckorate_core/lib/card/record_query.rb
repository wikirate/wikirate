class Card
  # Query lookup table for researched records
  # (See #new for handling of not-researched)
  class RecordQuery < LookupQuery
    include Sorting
    include RecordFilters
    include AdvancedFilters
    include ValueFilters
    include MetricFilters
    include CompanyFilters
    include OutlierFilter

    self.card_id_map = {
      research_policy: :policy_id,
      metric_type: :metric_type_id,
      designer: :designer_id,
      value_type: :value_type_id
    }.freeze
    self.card_id_filters = ::Set.new(card_id_map.keys).freeze
    self.simple_filters = ::Set.new(
      %i[company_id metric_id latest numeric_value route]
    ).freeze

    STATUS_GROUPS = { 0 => :unknown, 1 => :known, nil => :none }.freeze

    RESEARCHED_ANSWERS_ONLY =
      %i[value numeric_value updated check source calculated
         related_company_group].freeze

    class << self
      # instantiates AllRecordQuery object for searches that can return
      # not-researched records and RecordQuery
      # objects for all other searches
      def new filter, sorting={}, paging={}
        filter = filter.deep_symbolize_keys
        return super unless new_all_record_query? filter

        AllRecordQuery.new filter, sorting, paging
      end

      def new_all_record_query? filter
        # already AllRecord; don't re-init
        return false if self == AllRecordQuery

        all_record_query? filter
      end

      def all_record_query? filter
        # eg, if filtering by value, don't bother looking for not-yet-researched records
        RESEARCHED_ANSWERS_ONLY.each { |key| return false if filter[key].present? }

        # status is "all" or "none"
        filter[:status]&.to_sym.in? %i[all none]
      end
    end

    def lookup_class
      ::Record
    end

    def lookup_table
      "records"
    end

    def process_filters
      not_researched! if status_filter == :none
      super
    end

    private

    def main_results
      lookup_relation.map(&:card).compact
    end

    def status_filter
      @filter_args[:status]&.to_sym || :exists
    end

    def not_researched!
      # this case is only reached if there is a RESEARCHED_ANSWERS_ONLY filter and
      # the status filter is none. That combination guarantees there are no results.
      @empty_result = true
    end
  end
end
