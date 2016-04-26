# encoding: UTF-8

# -5 .. -3 2015  2018 .. 2020
class Formula
  def initialize formula_card
    @formula = formula_card
    @multi_year = false # formula involves more than the current years
    @fixed_years = ::Set.new
    @input_processor = []
  end


  def evaluate
    compile_formula
    compile_input_processor
    result = Hash.new { |h, k| h[k] = {} }
    @formula.input_values.each_pair do |company,  metrics_with_values_by_year|
      a_metric = metrics_with_values_by_year.keys.first
      years = metrics_with_values_by_year[a_metric].keys
      years.each do |year|
        next unless (value = get_value year.to_i, company)
        result[year][company] = normalize_value value
      end
    end
    result
  end

  # Returns all years that are affected by changes on the metric values given
  # by `changed_years`
  def update_range changed_years
    @multi_year ? :all : changed_years
    #return years unless @multi_year
  end

  def evaluate_single_input year, company
    expr = insert_into_formula year, metrics_with_values
    return if expr.match(/\{\{([^}]+)\}\}/) # missing input values
    compile expr
    normalize_value get_single_value(metrics_with_values)
  end

  def compile_formula expr=nil
    @executed_lambda = safe_execution(expr || to_lambda)
  end

  def get_single_value _metrics_with_values
    @executed_lambda
  end

  private

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

  # calculates a value for a year and a company
  # @param [Integer] year the year the value is calculated for
  # @param [Array] value_data an array with a hash for every metric nest in the
  # formula in order of appearance. The hashes must have the form
  # { year => value }
  # @return an array with the input for every metric in the formula
  def formula_input year, company
    value_data =
      @formula.input_metric_keys.map do |metric|
        @formula.input_values[company][metric]
      end
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
        return if v.blank?
        cast_input val
      end
    end
  end


  def safe_execution expr
    return unless safe_to_exec?(expr)
    exec_lambda expr
  end

  protected

  def cast_input val
    val
  end

  def safe_to_exec? expr
    false
  end

  def insert_into_formula year, metrics_with_values
    result = @formula.keyified
    metrics_with_values.each_pair do |metric, value|
      result.gsub! "{{#{metric}}}", value
    end
    result
  end

  def metrics
    @formula.input_metric_keys
  end

  def normalize_value value
    @formula.normalize_value value
  end
end
