class Card
  # Query lookup table for researched answers
  # (See #new for handling of not-researched)
  class AnswerQuery < LookupFilterQuery
    include Filtering
    include Sorting
    include AnswerFilters
    include ValueFilters
    include MetricAndCompanyFilters
    include OutlierFilter
    include RelationshipFilters

    STATUS_GROUPS = { 0 => :unknown, 1 => :known, nil => :none }.freeze

    RESEARCHED_ANSWERS_ONLY =
      %i[value numeric_value updated check source calculated
         related_company_group published].freeze

    class << self
      # instantiates AllAnswerQuery object for searches that can return
      # not-researched answers and AnswerQuery
      # objects for all other searches
      def new filter, sorting={}, paging={}
        filter = filter.deep_symbolize_keys
        return super unless new_all_answer_query? filter

        AllAnswerQuery.new filter, sorting, paging
      end

      def new_all_answer_query? filter
        # already AllAnswer; don't re-init
        return false if self == AllAnswerQuery

        all_answer_query? filter
      end

      def all_answer_query? filter
        # eg, if filtering by value, don't bother looking for not-yet-researched answers
        RESEARCHED_ANSWERS_ONLY.each { |key| return false if filter[key].present? }

        # status is "all" or "none"
        filter[:status]&.to_sym.in? %i[all none]
      end
    end

    attr_accessor :filter_args, :sort_args, :paging_args



    def process_filters
      not_researched! if status_filter == :none
      super
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

    def limit
      @paging_args[:limit]
    end

    def main_query
      answer_query
    end

    def answer_query
      q = Answer.where answer_conditions
      q = q.joins(@joins) if @joins.present?
      q
    end

    def answer_lookup
      sort_and_page { main_query }
    end

    # @return args for AR's where method
    def answer_conditions
      condition_sql([@conditions.join(" AND ")] + @values)
    end

    private

    def main_results
      # puts "SQL: #{answer_lookup.to_sql}"
      answer_lookup.answer_cards
    end

    def condition_sql conditions
      ::Answer.sanitize_sql_for_conditions conditions
    end

    def status_filter
      @filter_args[:status]&.to_sym || :exists
    end

    def not_researched!
      @empty_result = true
    end
  end
end
