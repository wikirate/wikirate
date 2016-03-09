class WolframFormula < Formula
  WL_INTERPRETER = 'https://www.wolframcloud.com/objects/92f1e212-7875-49f9-888f-b5b4560b7686'

  def get_value year, _metrics_with_values, i
    @executed_lambda[year.to_s][i]
  end

  # convert formula to a Wolfram Language expression
  # Example:
  # For formula {{metric A}}+{{metric B}} and two companies with
  # values in 2014 and 2015 for those metics return
  # (#[[1]]+#[[2]])&/@<|2015 -> {{1,2},{2,3}},2014-> {{4,5},{6,7}}|>
  def to_lambda
    wl_formula = @formula.keyified
    metrics.each_with_index do |metric, i|
      # indices in Wolfram Language start with 1
      wl_formula.gsub!("{{#{ metric }}}", "#[[#{ i + 1 }]]")
    end

    year_str = []
    @formula.input_values.each_pair do |year, companies|
      company_str = []
      companies.each do |_company, metrics_with_values|
        values = metrics.map do |metric|
          metrics_with_values[metric]
        end.compact
        next if values.size != metrics.size
        company_str << "{#{values.join(',')}}"
      end
      year_str << "\"#{year}\" -> {#{company_str.join ','}}"
    end
    wl_input = year_str.join ','

    "(#{wl_formula})&/@<| #{wl_input} |>"
  end

  def exec_lambda expr
    return unless safe_to_exec?(expr)
    uri = URI.parse(WL_INTERPRETER)
    # TODO: error handling
    response = Net::HTTP.post_form uri, 'expr' => expr
    begin
      result = JSON.parse(response.body)['Result']
      JSON.parse result
    rescue JSON::ParserError => e
      fail Card::Error, "failed to process wolfram formula: #{expr}"
    end
  end

  def safe_to_exec? expr
    true
  end
end