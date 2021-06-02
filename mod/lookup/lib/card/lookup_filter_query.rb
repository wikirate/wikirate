class Card
  class LookupFilterQuery
    attr_accessor :filter_args, :sort_args, :paging_args

    def initialize filter, sorting={}, paging={}
      @filter_args = filter
      @sort_args = sorting
      @paging_args = paging

      @conditions = []
      @joins = []
      @values = []
      @restrict_to_ids = {}

      process_sort
      process_filters
    end

    def lookup_query
      q = lookup_class.where lookup_conditions
      q = q.joins(@joins) if @joins.present?
      q
    end

    def condition_sql conditions
      lookup_class.sanitize_sql_for_conditions conditions
    end

    def lookup_relation
      sort_and_page { main_query }
    end

    # @return args for AR's where method
    def lookup_conditions
      condition_sql([@conditions.join(" AND ")] + @values)
    end

    # TODO: support optionally returning lookup objects

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
      lookup_query
    end

    private

    def process_filters
      normalize_filter_args
      return if @empty_result
      @filter_args.each { |k, v| process_filter_option k, v if v.present? }
      @restrict_to_ids.each { |k, v| filter k, v }
    end

    def normalize_filter_args
      # override
    end

    def simple_filters
      []
    end

    def card_id_filters
      []
    end

    def card_id_map
      {}
    end

    def process_filter_option key, value
      if (method = filter_method key)
        send method, key, value
      else
        try "#{key}_query", value
      end
    end

    def filter_method key
      case key
      when *simple_filters
        :filter_exact_match
      when *card_id_filters
        :filter_card_id
      end
    end

    def filter_exact_match key, value
      filter key, value if value.present?
    end

    def filter_card_id key, value
      return unless (card_id = to_card_id value)

      filter card_id_map[key], card_id
    end

    def to_card_id value
      if value.is_a?(Array)
        value.map { |v| Card.fetch_id(v) }
      else
        Card.fetch_id(value)
      end
    end

    def restrict_to_ids col, ids
      ids = Array(ids)
      @empty_result ||= ids.empty?
      restrict_lookup_ids col, ids
    end

    def restrict_lookup_ids col, ids
      existing = @restrict_to_ids[col]
      @restrict_to_ids[col] = existing ? (existing & ids) : ids
    end

    def restrict_by_cql col, cql
      cql.reverse_merge! return: :id, limit: 0
      restrict_to_ids col, Card.search(cql)
    end

    def filter field, value, operator=nil
      condition = "#{filter_table field}.#{field} #{op_and_val operator, value}"
      add_condition condition, value
    end

    def filter_table _field
      lookup_table
    end

    def op_and_val op, val
      "#{db_operator op, val} #{db_value val}"
    end

    def add_condition condition, value
      @conditions << condition
      @values << value
    end

    def db_operator operator, value
      operator || (value.is_a?(Array) ? "IN" : "=")
    end

    def db_value value
      value.is_a?(Array) ? "(?)" : "?"
    end
  end
end
