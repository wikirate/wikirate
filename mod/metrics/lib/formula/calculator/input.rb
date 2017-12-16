module Formula
  class Calculator
    # It finds all metric values and yearly values that are related to the
    # the metrics and yearlys variables of a formula and prepares the values
    # for calculating the formula values
    # The key method is #each that iterates over all
    # company and year combination that could possible get a calculated value
    # and provides the input data for the calculation
    class Input
      # @param [Array<Card>] input_cards all cards that are part of the formula
      # @param [Array<String] year_options for every input card a year option
      # @param [Proc] input_cards a block that is called for every input value
      def initialize input_cards, year_options, &input_cast
        @input_cards = input_cards
        @input_cast = input_cast
        @all_fetched = false
        @year_options_processor = YearOptionsProcessor.new year_options
      end

      # @param [Hash] opts restrict input values
      # @option opts [String] :company only yield input for given company
      # @option opts [String] :year only yield input for given year
      def each opts={}
        fetch_values opts
        fixed_company = opts[:company]&.to_name&.key
        years = opts[:year] ? Array(opts[:year].to_i) : years_with_values
        years.each do |year|
          if fixed_company
            next unless companies_with_value(year).include?(fixed_company)
            next unless (value = input_for(year, fixed_company))
            yield(value, fixed_company, year)
          else
            companies_with_value(year).each do |company_key|
              next unless (value = input_for(year, company_key))
              yield(value, company_key, year)
            end
          end
        end
      end

      # type of input
      # either :yearly_variable or, if it's a metric, the value type as string
      def type index
        @order[index][1]
      end

      def key index
        @order[index][0]
      end

      def companies_with_value year
        @companies_with_values_by_year[year].to_a
      end

      def years_with_values
        @companies_with_values_by_year.keys
      end

      def input_for year, company
        fetch_values company: company, year: year unless @all_fetched
        values_for_all_years = all_values_for company.to_name.key
        values = @year_options_processor.run values_for_all_years, year
        validate_input values
      end

      private

      def validate_input input
        return if !input || !input.is_a?(Array)
        input.map do |val|
          return if val.blank?
          if val.is_a?(Array)
            val.map do |v|
              return if v.blank?
              @input_cast.call v
            end
          else
            @input_cast.call val
          end
        end
      end

      def fetch_values opts={}
        return if @all_fetched
        @all_fetched ||= opts.empty?

        @metric_values = Hash.new_nested Hash, Hash
        @yearly_values = Hash.new_nested Hash

        # nil as initialization is important here
        # nil means not yet searched for companies with values
        # empty means no companies with values for all input cards
        @companies_with_values =
          opts[:company] ? ::Set.new([opts[:company].to_name.key]) : nil

        @companies_with_missing_values = ::Set.new
        @companies_with_values_by_year = Hash.new_nested ::Set
        @order = []

        @input_cards.each do |input_card|
          case input_card.type_id
          when Card::MetricID
            metric_value_fetch input_card, opts
            @order << [input_card.key, input_card.value_type]
          when Card::YearlyVariableID
            yearly_value_fetch input_card
            @order << [input_card.key, :yearly_value]
          end
          next unless @companies_with_values&.empty?
          # there are no companies with values for all input cards
          @companies_with_values_by_year = Hash.new_nested ::Set
          return
        end
        clean_companies_with_value_by_year
      end

      # if a company doesn't have at least one value for all input cards
      # remove it completely
      def clean_companies_with_value_by_year
        @companies_with_values_by_year =
          @companies_with_values_by_year.to_a.each.with_object({}) do |(k, v), h|
            h[k] = v & @companies_with_values
          end
      end

      def metric_value_fetch input_card, opts={}
        search_restrictions = {
          metrics: input_card.name.to_s,
          companies: @companies_with_values.to_a
        }
        if opts[:year] && !@year_options_processor.multi_year
          search_restrictions[:year] = opts[:year]
        end
        v_cards = input_metric_value_cards search_restrictions

        filter_companies ::Set.new(v_cards.map(&:company_key))

        v_cards.each do |vc|
          @metric_values[vc.metric_key][vc.company_key][vc.year.to_i] = vc.value
          @companies_with_values_by_year[vc.year.to_i] << vc.company_key
        end
      end

      def filter_companies company_keys
        @companies_with_values =
          if @companies_with_values
            @companies_with_missing_values.merge(
              @companies_with_values ^ company_keys
            )
            @companies_with_values & company_keys
          else
            company_keys
          end
      end

      def yearly_value_fetch input_card
        v_cards = input_yearly_value_cards(variables: input_card.name)
        v_cards.each do |vc|
          @yearly_values[input_card.key][vc.year.to_i] = vc.content
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
        if opts[:metrics].present?
          left_left[:left] = { name: ["in"] + Array.wrap(opts[:metrics]) }
        end
        if opts[:companies].present?
          left_left[:right] = { name: ["in"] + Array.wrap(opts[:companies]) }
        end
        query = { right: "value", left: { type_id: Card::MetricValueID } }
        query[:left][:left] = left_left if left_left.present?
        query[:left][:right] = opts[:year].to_s if opts[:year]
        query
      end

      def yearly_value_cards_query opts={}
        query = { type_id: Card::YearlyValueID }
        if opts[:variables]
          query[:left] =
            { left: { name: ["in"] + Array.wrap(opts[:variables]) } }
        end
        query
      end
    end
  end
end
