class Formula
  class Input
    def initialize formula_card
      @formula = formula_card
      @multi_year = false # formula involves more than the current years
      @fixed_years = ::Set.new
      @all_fetched = false
    end

    def each opts={}
      fetch_values opts
      years = opts[:year] ? [opts[:year]] : @years_with_values
      years.each do |year|
        @companies_with_values.each do |company|
          next unless (ip = input_for(year, company))
          yield(ip, company, year)
        end
      end
    end

    def type index
      @order[index][1]
    end

    def key index
      @order[index][0]
    end

    # @param [Integer] year the year the value is calculated for
    # @param [Array] value_data an array with a hash for every metric nest in the
    # formula in order of appearance. The hashes must have the form
    # { year => value }
    # @return an array with the input for every metric in the formula
    def input year=nil, company=nil
      if year && company
        input_for year, company
      else
        result = Hash.new_nested Hash
        each do |ip, company, year|
          result[year][company] = ip
        end
      end
    end

    def input_for year, company
      fetch_values company: company, year: year unless @all_fetched
      values_for_all_years = all_values_for company.to_name.key
      values = year_args_processor.run value_data, year
      validate_input values
    end

    private

    def validate_input input
      input.map do |val|
        if val.is_a?(Array)
          val.map do |v|
            return if v.blank?
            @formula.cast_input v
          end
        else
          return if val.blank?
          @formula.cast_input val
        end
      end
    end

    def fetch_values opts={}
      return if @all_fetched
      @all_fetched ||= opts.empty?

      @metric_values = Hash.new_nested Hash, Hash
      @yearly_values = Hash.new_nested Hash
      @companies_with_values = opts[:company] ? [opts[:company]] : nil
      @years_with_values = HAsh.new_nested ::Set
      @order = []

      @formula.each_nested_chunk do |chunk|
        case chunk.referee_card.type_id
        when Card::MetricID
          metric_value_fetch chunk, opts
          @order << [chunk.referee_card.key, chunk.referee_card.value_type]
        when Card::YearlyVariableID
          yearly_value_fetch chunk
          @order << [chunk.referee_card.key, :yearly_value]
        else
          @formula.errors.add :formula,
                              "invalid formula input #{chunk.referee_name}"
        end
      end
    end

    def metric_value_fetch chunk, opts={}
      search_restrictions = {
        metrics: chunk.referee_name.to_s,
        companies: @companies_with_values
      }
      if opts[:year] && !@multi_year
        search_restrictions[:year] = opts[:year]
      end
      v_cards = input_metric_value_cards search_restrictions

      @companies_with_values =
        if @companies_with_values
          @companies_with_values & v_cards.map(&:company_key)
        else
          v_cards.map(&:company_key)
        end

      v_cards.each do |vc|
        @metric_values[vc.metric_key][vc.company_key][vc.year.to_i] = vc.value
        @years_with_values[vc.year.to_i] << vc.company_key
      end
    end

    def yearly_value_fetch chunk
      v_cards = input_yearly_value_cards(variables: chunk.referee_name)
      v_cards.each do |vc|
        @yearly_values[chunk.referee_card.key] = vc.content
        @years_with_values[vc.year.to_i] << chunk.referee_card.key
      end
    end

    def all_values_for company, year=nil
      @order.map do |name, type|
        val =
          case type
          when :yearly_value
            @yearly_values[name]
          else
            @metric_values[name][company]
          end
        return nil unless val
        year ? val[year] : val
      end
    end

    def year_args_processor
      @year_args_processor ||= YearArgsProcessor.new @formula.content
    end

    # Searches for all metric value cards that are necessary to calculate all values
    # If a company (and a year) is given it returns only the metric value cards that
    # are needed to calculate the value for that company (and that year)
    # @param [Hash] opts ({})
    # @option [String] :company
    # #option [String] :year
    def input_metric_value_cards opts={}
      ::Card.search metric_value_cards_query(opts)
    end

    def input_yearly_value_cards opts={}
      ::Card.search yearly_value_cards_query(opts)
    end

    def metric_value_cards_query opts={}
      left_left = {}
      if opts[:metrics]
        left_left[:left] = { name: ['in'] + Array.wrap(opts[:metrics]) }
      end
      if opts[:companies]
        left_left[:right] = { name: ['in'] + Array.wrap(opts[:companies]) }
      end
      query = { right: 'value', left: { type_id: Card::MetricValueID } }
      query[:left][:left] = left_left if left_left.present?
      query[:left][:right] = opts[:year].to_s if opts[:year]
      query
    end

    def yearly_value_cards_query opts={}
      query =  { type_id: Card::YearlyValueID }
      if opts[:variables]
        query[:left] = { name: ['in'] + Array.wrap(opts[:variables]) }
      end
      query
    end
  end
end