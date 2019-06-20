class Card
  class AnswerQuery
    include Filtering
    include AnswerFilters
    include MetricAndCompanyFilters
    include Where

    def self.new filter, sorting={}, paging={}
      filter.deep_symbolize_keys!
      if filter[:status]&.to_sym.in?(%i[all none]) && self != AllQuery
        AllQuery.new filter, sorting, paging
      else
        super
      end
    end

    def initialize filter, sorting={}, paging={}
      @filter_args = filter
      @sort_args = sorting
      @paging_args = paging

      @conditions = []
      @values = []
      @restrict_to_ids = {}

      process_sort
      process_filters
    end

    # TODO: support optionally returning answer objects

    # @return array of metric answer card objects
    #   if filtered by missing values then the card objects
    #   are newly instantiated and not in the database
    def run
      result_array { sort_and_page { answer_query }.answer_cards }
    end

    def result_array
      @empty_result ? [] : yield
    end

    def answer_query
      Answer.where answer_conditions
    end

    def sort_and_page
      yield.sort(@sort_args).paging(@paging_args)
    end

    def process_filters
      @filter_args.each { |k, v| process_filter_option k, v if v.present? }
      @restrict_to_ids.each { |k, v| filter k, v }
    end

    def count

    end

    def value_count

    end

    def limit
      @paging_args[:limit]
    end

    def process_sort
      return unless single_metric? && @sort_args[:sort_by]&.to_sym == :value
      if metric_card.numeric? || metric_card.relationship?
        @sort_args[:sort_by] = :numeric_value
      end
    end
  end
end
