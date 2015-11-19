def evaluate_expression expr
  return 0 unless valid_ruby_expression?(expr)
  normalize_value eval(expr)
end

def evaluate_formula input_values
  rb_formula = prepare_formula input_values
  result = Hash.new { |h,k| h[k] = {} }
  input_values.each_pair do |year, companies|
    companies.each do |company, metrics_with_values|
      result[year][company] =
        normalize_value rb_formula.call(metrics_with_values.values)
    end
  end
  result
end


def prepare_formula values
  binding.pry
  rb_formula = formula.clone
  metrics = extract_metrics
  metrics.each_with_index do |metric, i|
    rb_formula.gsub!("{{#{ metric }}}", "args[#{ i+1 }]")
  end
  rb_formula = 0 unless valid_ruby_expression?(rb_formula)
  eval "lambda { |args| #{rb_formula}}"
end

# allow only numbers, whitespace, mathematical operations and args references
def valid_ruby_expression? expr
  expr.gsub(/args\[\d+\]/,'').match(/^[\s\d+-\/*\.()]*$/)
end


