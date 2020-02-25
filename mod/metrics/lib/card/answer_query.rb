class Card
  # Query lookup table for researched answers
  # (See #new for handling of not-researched)
  class AnswerQuery
    include Filtering
    include AnswerFilters
    include MetricAndCompanyFilters
    include OutlierFilter

    STATUS_GROUPS = { 0 => :unknown, 1 => :known, nil => :none }.freeze

    RESEARCHED_ANSWERS_ONLY =
      %i[value numeric_value related_company_group source updated calculated check].freeze

    class << self
      # instantiates AllAnswerQuery object for searches that can return
      # not-researched answers and AnswerQuery
      # objects for all other searches
      def new filter, sorting={}, paging={}
        filter = filter.deep_symbolize_keys
        if new_all_answer_query? filter
          AllAnswerQuery.new filter, sorting, paging
        else
          super
        end
      end

      def new_all_answer_query? filter
        # already AllAnswer; don't re-init
        return false if self == AllAnswerQuery

        # eg, if filtering by value, don't bother looking for not-yet-researched answers
        RESEARCHED_ANSWERS_ONLY.each { |key| return false if filter[key].present? }

        # status is "all" or "none"
        filter[:status]&.to_sym.in?(%i[all none])
      end
    end

    attr_accessor :filter_args, :sort_args, :paging_args

    def initialize filter, sorting={}, paging={}
      @filter_args = filter
      @sort_args = sorting
      @paging_args = paging

      @conditions = []
      @values = []
      @restrict_to_ids = {}

      not_researched! if status_filter == :none
      process_sort
      process_filters
    end

    # TODO: support optionally returning answer objects

    # @return array of metric answer card objects
    #   if filtered by missing values then the card objects
    #   are newly instantiated and not in the database
    def run
      @empty_result ? [] : main_results
    end

    # @return [Array]
    def count
      @empty_result ? 0 : main_query.count
    end

    # @return [Hash] with a key for each group and a count as the value
    def count_by_group group
      main_query.group(group).count
    end

    # @return [Hash] with a key for each status and a count as the value
    def count_by_status
      if status_filter.in? %i[all exists]
        count_by_status_groups
      else
        { status_filter => count }
      end
    end

    def count_by_status_groups
      counts = { total: 0 }
      count_by_group("value <> 'Unknown'").each do |val, count|
        num = count.to_i
        counts[STATUS_GROUPS[val]] = num
        counts[:total] += num
      end
      counts
    end

    def limit
      @paging_args[:limit]
    end

    def main_query
      answer_query
    end

    def answer_query
      Answer.where answer_conditions
    end

    def answer_lookup
      sort_and_page { main_query }
    end

    # @return args for AR's where method
    def answer_conditions
      condition_sql([@conditions.join(" AND ")] + @values)
    end

    private

    def status_filter
      @filter_args[:status]&.to_sym || :exists
    end

    def main_results
      answer_lookup.answer_cards
    end

    def condition_sql conditions
      ::Answer.sanitize_sql_for_conditions conditions
    end

    def sort_and_page
      yield.sort(@sort_args).paging(@paging_args)
    end

    def process_sort
      return unless numeric_sort?

      @sort_args[:sort_by] = :numeric_value
    end

    def numeric_sort?
      single_metric? &&
        @sort_args[:sort_by]&.to_sym == :value &&
        (metric_card.numeric? || metric_card.relationship?)
    end

    # overridden in AllAnswerQuery.
    # this method is only reached in AnswerQuery instances if there is a
    # RESEARCHED_ANSWERS_ONLY filter and the status filter is none.
    # That combination guarantees there are no results.
    def not_researched!
      @empty_result = true
    end
  end
end
