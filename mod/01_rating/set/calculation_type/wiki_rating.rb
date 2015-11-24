def evaluate_expression expr
  return 0 unless valid_ruby_expression?(expr)
  normalize_value eval(expr)
end

def evaluate_formula input_values
  rb_formula = prepare_formula input_values
  result = Hash.new { |h,k| h[k] = {} }
  metrics = extract_metric_keys
  input_values.each_pair do |year, companies|
    companies.each do |company, metrics_with_values|
      values = metrics.map do |metric|
        if (v = metrics_with_values[metric])
          v.to_f
        else
          nil
        end
      end.compact
      next if values.size != metrics.size
      result[year][company] =
        normalize_value rb_formula.call(values)
    end
  end
  result
end


def prepare_formula values
  rb_formula = keyify_formula formula.clone
  metrics = extract_metric_keys
  metrics.each_with_index do |metric, i|
    rb_formula.gsub!("{{#{ metric }}}", "args[#{ i }]")
  end
  rb_formula = 0 unless valid_ruby_expression?(rb_formula)
  eval "lambda { |args| #{rb_formula}}"
end

# allow only numbers, whitespace, mathematical operations and args references
def valid_ruby_expression? expr
  expr.gsub(/args\[\d+\]/,'').match(/^[\s\d+-\/*\.()]*$/)
end


