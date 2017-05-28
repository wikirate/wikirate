class Card
  class AllAnswerQuery
    def initialize filter, paging
      @filter = filter.clone
      @filter.delete :metric_value # if we are here this is "all"
      @paging = paging || {}

      @base_card = Card[@filter.delete(base_key)]
      @year = @filter.delete :year
      add_filter @filter_args
    end

    def self.default fixed_id, sort={}, paging={}
      new fixed_id, { latest: true }, sort, paging
    end

    # @return array of metric answer card objects
    #   if filtered by missing values then the card objects
    #   are newly instantiated and not in the database
    def run
      subject_ids = Card.search @filter_wql, return: :id
      subject_ids.map do |id|
        fetch_answer id
      end
    end

    def fetch_answer id
      fetch_existing_answer(id) || fetch_missing_answer(id)
    end

    def fetch_existing_answer id
      Answer.fetch(existing_where_args.merge(subject_key => id)).first
    end

    def fetch_missing_answer id
      Card.new name: new_name(Card.fetch_name(id)), type_id: MetricValueID
    end

    def add_filter opts={}
      @filter_wql = @paging
      opts.each do |k, v|
        process_filter_option k, v if v.present?
      end
    end

    def existing_where_args
      return @where_args if @where_args

      @where_args = { base_key => @base_card.id }
      if !@year || @year.to_sym == :latest
        @where_args[:latest] = true
      else
        @where_args[:year] = @year
      end
      @where_args
    end

    def where additional_filter={}
      Answer.where where_args(additional_filter)
    end

    def count additional_filter={}
      return missing_answer_query.count if find_missing?
      where(additional_filter).count
    end

    def value_count additional_filter={}
      where(additional_filter).select(:value).uniq.count
    end

    def category_query value
      filter :value, value
    end

    def limit
      @paging[:limit]
    end

    private

    def prepare_filter_args filter
      @filter_args = filter.deep_symbolize_keys
      @filter_args[:latest] = true unless filter[:year] || filter[:metric_value]
    end

    def prepare_sort_args args
      @sort_args = args
    end

    # @return args for AR's where method
    def where_args temp_filter_opts={}
      set_temp_filter temp_filter_opts
      @restrict_to_ids.each do |key, values|
        filter key, values
      end
      [(@conditions + @temp_conditions).join(" AND ")] + @values + @temp_values
    end

    def process_filter_option key, value
      if respond_to? "#{key}_wql"
        @filter_wql.merge! send("#{key}_wql", value)
      end
    end

    def to_card_id value
      if value.is_a?(Array)
        value.map { |v| Card.fetch_id(v) }
      else
        Card.fetch_id(value)
      end
    end

    private

    def year
      @year || Time.now.year
    end

    def new_name company
      "#{@metric_card.name}+#{company}+#{year}"
    end
  end
end
