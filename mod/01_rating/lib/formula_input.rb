class FormulaInput
  def initialize formula_card
    @formula = formula_card
    @multi_year = false # formula involves more than the current years
    @fixed_years = ::Set.new
    @input_processor = []

    fetch_all_values
    compile_input_processor
  end

  def each_input
    @years_with_values.each do |year|
      @companies_with_values.each do |company|
        next unless (ip = input(year, company))
        yield(year, company, ip)
      end
    end
  end

  # calculates a value for a year and a company
  # @param [Integer] year the year the value is calculated for
  # @param [Array] value_data an array with a hash for every metric nest in the
  # formula in order of appearance. The hashes must have the form
  # { year => value }
  # @return an array with the input for every metric in the formula
  def input year, company
    value_data = get_input company
    values =
      @input_processor.map.with_index do |ip, i|
        case ip
        when Integer
          year?(ip) ? value_data[i][ip] : value_data[i][year + ip]
        when Array
          ip.map { |year| data[i][year] }
        when Proc
          ip.call(year).map { |y| value_data[i][y] }
        else
          fail Card::Error, "illegal input processor type: #{ip.class}"
        end
      end
    validate_input values
  end

  def validate_input input
    input.map do |val|
      if val.is_a?(Array)
        val.map do |v|
          return if v.blank?
          cast_input v
        end
      else
        return if val.blank?
        cast_input val
      end
    end
  end

  private

  def fetch_all_values
    @metric_values =
      Hash.new { |h1, k1| h1[k1] = Hash.new { |h2, k2| h2[k2] = {} } }
    @yearly_values =Hash.new { |h1, k1| h1[k1] = {} }
    @companies_with_values = nil
    @years_with_values = Hash.new { |h1, k1| h1[k1] = ::Set.new }
    @order = []

    formula_card.each_nested_chunk do |chunk|
      case chunk.referee_card.type_id
      when MetricID
        v_cards = input_metric_value_cards metrics: chunk.referee_name,
                                           companies: companies_with_values

        companies_with_values =
          if companies_with_values
            companies_with_values & v_cards.map(&:company_key)
          else
            v_cards.map(&:company_key)
          end

        v_cards.each do |vc|
          @metric_values[vc.metric_key][vc.company_key][vc.year.to_i] = vc.value
          @years_with_values[vc.year.to_i] << vc.company_key
        end
        @order << { chunk.referee_card.key => :metric_value }
      when YearlyVariableID
        input_yearly_variable_value_cards.each do |vc|
          @yearly_values[chunk.referee_card.key] = vc.content
          @years_with_values[vc.year.to_i] << chunk.referee_card.key
        end
        @order << { chunk.referee_card.key => :yearly_value }
      else
        errors.add :formula, "invalid formula input #{chunk.referee_name}"
      end
    end
  end

  def get_input company, year=nil
    @order.map do |name, type|
      val =
        case type
        when :metric_value
          @metric_values[name][company]
        when :yearly_value
          @yearly_values[name]
        end
      return nil unless val
      year ? val[year] : val
    end
  end


  def compile_input_processor
    @formula.content.scan(/\{\{(?<metric>[^|}]+)(?:\|(?<year>[^}]*))?\}\}/) do
    |match|
      @input_processor <<
        if $~[:year]
          interpret_year_expr normalize_year_expr($~[:year])
        else
          0
        end
      if (cur = @input_processor.last) != 0
        @multi_year = true
        @fixed_years << cur if year?(cur)
      end
    end
  end

  def normalize_year_expr expr
    expr.sub('year:','').tr('?', '0').strip
  end

  def year? y
    y.is_a?(Integer) && y > 1000
  end

  def interpret_year_expr expr
    case expr
    when /^[0?]$/ then 0
    when /^[+-]?\d+$/ then expr.to_i
    when /,/
      years = expr.split(',').map(&:to_i)
      year_list years
    when /\.\./ then
      start, stop = expr.split('..').map(&:to_i)
      year_range(start, stop)
    end
  end

  def year_list list
    return list if list.all? { |y| year? y }
    proc do |year|
      list.map do |year_offset|
        if year? year_offset
          year_offset
        else
          year + year_offset
        end
      end
    end
  end

  def year_range start, stop
    if year?(start) && year?(stop)
      (start..stop).to_a
    elsif !year?(start) && !year?(stop)
      proc do |year|
        (year+start..year+stop).to_a
      end
    elsif !year?(start)
      proc do |year|
        (year+start..stop).to_a
      end
    else
      proc do |year|
        (year..year+stop).to_a
      end
    end
  end

  # Searches for all metric value cards that are necessary to calculate all values
  # If a company (and a year) is given it returns only the metric value cards that
  # are needed to calculate the value for that company (and that year)
  # @param [Hash] opts ({})
  # @option [String] :company
  # #option [String] :year
  def input_metric_value_cards opts={}
    ::Card.search metric_value_cards_query(opts.merge(metrics: input_metric_keys))
  end

  def input_yearly_value_cards opts={}
    ::Card.search value_cards_query(opts.merge(metrics: input_metric_keys))
  end

  def metric_value_cards_query opts={}
    left_left = {}
    if opts[:metrics]
      left_left[:left] = { name: ['in'] + Array.wrap(opts[:metrics]) }
    end
    if opts[:companies]
      left_left[:right] = { name: ['in'] + Array.wrap(opts[:companies]) }
    end
    query = { right: 'value', left: { type_id: MetricValueID } }
    query[:left][:left] = left_left if left_left.present?
    query[:left][:right] = opts[:year] if opts[:year]
    query
  end

  def yearly_value_cards_query opts={}
    query =  { type_id: YearlyValueID }
    if opts[:variables]
      query[:left] = { name: ['in'] + Array.wrap(opts[:variables]) }
    end
    query
  end
end