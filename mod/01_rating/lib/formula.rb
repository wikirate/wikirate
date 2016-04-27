# encoding: UTF-8


# -5 .. -3 2015  2018 .. 2020
class Formula
  def self.new_formula formula_card
    if formula_card.wiki_rating?
      WikiRatingFormula.new formula_card
    elsif TranslateFormula.valid_formula? formula_card.content
      TranslateFormula.new formula_card
    elsif RubyFormula.valid_formula? formula_card.content
      RubyFormula.new formula_card
    else
      WolframFormula.new formula_card
    end
  end

  def initialize formula_card
    @formula = formula_card
  end

  def evaluate
    compile_formula
    result = Hash.new { |h, k| h[k] = {} }
    FormulaInput.new(@formula).each_input |year, company, input|
      next unless (value = get_value(input))
      result[year][company] = normalize_value value
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
