class Card
  class MetricAnswerQuery
    def initialize filter_args
      @filter_args = filter_args
      @conditions = []
      @values = []
      @restrict_to_ids = Hash.new { |h, k| h[k] = [] }
    end

    # @return array of metric answer card objects
    #   if filtered by missing values then the card objects
    #   are newly instantiated and not in the database
    def run
      return missing_answers if find_missing?
      run_filter_query
    end

    private

    def find_missing?
      @filter_args[:metric_value] == :none
    end

    def run_filter_query
      MetricAnswer.fetch(*where_args)
    end

    # @return args for AR's where method
    def where_args
      @filter_args.each do |key, value|
        if exact_match_filters.include? key
          filter key, value
        elsif like_filters.include? key
          filter key, "%#{value}%", "LIKE"
        elsif respond_to? "#{key}_query"
          send "#{key}_query", value
        end
      end
      @restrict_to_ids.each do |key, values|
        filter key, values
      end
      [@conditions.join(" AND ")] + @values
    end

    def filter_key_to_db_column key
      key
    end

    def exact_match_filters
      ::Set.new
    end

    def like_filters
      ::Set.new
    end

    def filter key, value, operator=nil
      operator ||= value.is_a?(Array) ? "IN" : "="
      db_column = filter_key_to_db_column key
      @conditions << "#{db_column} #{operator} (?)"
      @values << value
    end
  end
end
