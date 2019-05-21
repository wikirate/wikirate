class Card
  class AnswerQuery
    include FilterOptions
    include FieldConditions
    include AllAndMissing
    include Where

    DB_COLUMN_MAP = {}.freeze

    def initialize filter, sorting={}, paging={}
      prepare_filter_args filter
      prepare_sort_args sorting
      @paging_args = paging

      @conditions = []
      @values = []
      @restrict_to_ids = {}

      @temp_conditions = []
      @temp_values = []
      @temp_restrict_to_ids = {}

      add_filter @filter_args
    end

    # TODO: support optionally returning answer objects

    # @return array of metric answer card objects
    #   if filtered by missing values then the card objects
    #   are newly instantiated and not in the database
    def run
      if find_all?
        all_answers # does not actually find calculated!
      elsif find_missing?
        missing_answers # not researched
      else
        known_answers
      end
    end

    def add_filter opts={}
      opts.each do |k, v|
        process_filter_option k, v if v.present?
      end
    end

    def count additional_filter={}
      return missing_answer_query.count if find_missing?(additional_filter)
      where(additional_filter).count
    end

    def value_count additional_filter={}
      where(additional_filter).select(:value).uniq.count
    end

    def limit
      @paging_args[:limit]
    end

    def answer_lookup
      # Rails.logger.warn "where_args: #{where_args}"
      where.sort(@sort_args).paging(@paging_args)
    end

    private

    def restrict_to_ids col, ids
      ids = Array(ids)
      @empty_result = ids.empty?
      if @restrict_to_ids[col]
        @restrict_to_ids[col] &= ids
      else
        @restrict_to_ids[col] = ids
      end
    end

    def known_answers
      return [] if @empty_result
      answer_lookup.answer_cards.compact
    end

    def prepare_filter_args filter
      @filter_args = filter.deep_symbolize_keys
    end

    def prepare_sort_args args
      @sort_args = args
    end
  end
end
