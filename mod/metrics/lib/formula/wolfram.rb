module Formula
  class Wolfram < Calculator
    INTERPRETER = "https://www.wolframcloud.com/objects/92f1e212-7875-49f9-888f-b5b4560b7686"
    WHITELIST = ::Set.new(
      %w[Boole If Switch Map
         Count Pick Cases FirstCase
         MaximalBy MinimalBy
         AllTrue AnyTrue NoneTrue
         Sort SortBy
         Take TakeLargest TakeSmallest TakeLargestBy TakeSmallestBy
         Mean Variance StandardDeviation Median Quantile Covariance]
    ).freeze

    # INPUT_CAST = lambda { |val| val == 'Unknown' ? 'Unknown'.to_f }
    # To reduce the Wolfram Cloud calls the Wolfram calculator
    # calculates all values at once when it compiles the formula and saves
    # the result in @executed_lambda
    # Getting the value is just fetching the value from a hash
    def get_value _input, company, year
      @executed_lambda[year.to_s][@company_index[company]]
    end

    # Converts the formula to a Wolfram Language expression
    # Example:
    # For formula {{metric M1}}+{{metric M2}} and two companies C1 and C1 with
    # values in 2014 and 2015:
    # M1+C1+2014 = 11.14, M2+C1+2014 = 21.14
    # M1+C1+2015 = 11.15, M2+C1+2015 = 21.15
    # M1+C2+2014 = 12.14, M2+C2+2014 = 22.14
    # M1+C2+2015 = 12.15, M2+C2+2015 = 22.15
    # create the following expression in Wolfram Language
    # Apply[(#1+#2)&,<|2014 -> {{11.14, 21.14}, {12.14, 22.14}},
    #                 2015 -> {{11.15, 21.15}, {12.15, 22.15}}|>, {2}]
    # The result is a Wolfram hash with an array for every year that contains
    # the values for all companies
    # <|2014 -> {32.28, 34.28}, 2015 -> {32.30, 34.30}|>
    def to_lambda
      @company_index = {}
      wl_formula =
        replace_nests do |i|
          # indices in Wolfram Language start with 1
          "##{i + 1}"
        end

      year_str = []
      input_by_year = Hash.new_nested Array
      company_index = 0
      @input.each do |input_values, company, year|
        @company_index[company] = company_index
        company_str =
          input_values.map.with_index do |value, i|
            if value == "Unknown"
              "\"#{value}\""
            else
              @input.type(i) == "Number" ? value : "\"#{value}\""
            end
          end.join(",")
        input_by_year[year] << "{#{company_str}}"
        company_index += 1
      end
      input_by_year.each_pair do |year, values|
        year_str << "\"#{year}\" -> {#{values.join ','}}"
      end
      wl_input = year_str.join ","
      "Apply[(#{wl_formula})&,<| #{wl_input} |>,{2}]"
    end

    protected

    # Sends a Wolfram language expression to the Wolfram cloud. Fetches and
    # validates the result.
    # @param [String] expr an expression in Wolfram language that returns json
    #   when evalualed in the Wolfram cloud
    # @return the parsed response
    def exec_lambda expr
      uri = URI.parse(INTERPRETER)
      # TODO: error handling
      response = Net::HTTP.post_form uri, "expr" => expr

      begin
        body = JSON.parse(response.body)
        if body["Success"]
          JSON.parse body["Result"]
        else
          @errors << "wolfram syntax error: #{body['MessagesText'].join("\n")}"
          return false
        end
      rescue JSON::ParserError => e
        raise Card::Error, "failed to parse wolfram result: #{expr}"
      end
    end

    def save_to_convert? expr
      not_on_whitelist =
        expr.gsub(/\{\{([^}])+\}\}/, "").gsub(/"[^"]+"/, "")
            .scan(/[a-zA-Z][a-zA-Z]+/).reject do |word|
          WHITELIST.include? word
        end
      return true if not_on_whitelist.empty?
      not_on_whitelist.each do |_bad_word|
        @errors << "#{not_on_whitelist.first} forbidden keyword"
      end
      false
    end

    def safe_to_exec? _expr
      true
    end
  end
end
