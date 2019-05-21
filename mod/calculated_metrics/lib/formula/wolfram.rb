require_dependency "wolfram/unknowns"

module Formula
  class Wolfram < NestFormula
    include Unknowns
    include Validation

    INTERPRETER =
      "https://www.wolframcloud.com/objects/92f1e212-7875-49f9-888f-b5b4560b7686".freeze

    FUNC_DEFS = ["Zeros[x_] := Count[x, 0]",
                 'Unknowns[x_] := Count[x, "Unknown"]'].freeze

    COMMAND_JOINT = ";".freeze

    # INPUT_CAST = lambda { |val| val == 'Unknown' ? 'Unknown'.to_f }
    # To reduce the Wolfram Cloud calls the Wolfram calculator
    # calculates all values at once when it compiles the formula and saves
    # the result in @executed_lambda
    # Getting the value is just fetching the value from a hash
    def get_value _input, company, year
      @executed_lambda[year.to_s][@company_index[year.to_s][company]]
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
      with_function_defs "Apply[(#{wl_formula})&,<| #{wl_input} |>,{2}]"
    end

    protected

    def with_function_defs wl_input
      (FUNC_DEFS + [wl_input]).join COMMAND_JOINT
    end

    # Sends a Wolfram language expression to the Wolfram cloud. Fetches and
    # validates the result.
    # @param [String] expr an expression in Wolfram language that returns json
    #   when evaluated in the Wolfram cloud
    # @return the parsed response
    def exec_lambda expr
      return unless (parsed = parse_wolfram_response post_wolfram_request(expr))

      insert_unknown_results parsed
    end

    def post_wolfram_request expr
      uri = URI.parse INTERPRETER
      Net::HTTP.post_form uri, "expr" => expr
    rescue StandardError => e
      log_wolfram_error "request failed", e.message
    end

    def parse_wolfram_response response
      return unless response.present? && (body = parse_wolfram_json :body, response.body)

      if body["Success"]
        parse_wolfram_json :result, body["Result"]
      else
        wolfram_syntax_error body["MessagesText"]
      end
    end

    def parse_wolfram_json type, json
      JSON.parse json
    rescue JSON::ParserError => _e
      log_wolfram_error "bad JSON in #{type}", "JSON = #{json}\n#{e.message}"
    end

    def log_wolfram_error main, extra
      main = "Wolfram Error: #{main}"
      @errors << main
      Rails.logger.debug "#{main}: #{extra}"
      false
    end

    def wolfram_syntax_error messages
      @errors << "Wolfram Error:\n  #{messages&.join("\n  ")}"
      false
    end

    private

    # Formula in Wolfram language
    def wl_formula
      replace_nests do |i|
        # indices in Wolfram Language start with 1
        "##{i + 1}"
      end
    end

    # Input for the Wolfram Formula in Wolfram Language to
    # calculate all values
    def wl_input
      year_str = []
      wl_input_by_year.each_pair do |year, values|
        year_str << "\"#{year}\" -> {#{values.join ','}}"
      end
      year_str.join ","
    end

    # @return Hash with the input in Wolfram Language to calculate the values
    #   for every year
    def wl_input_by_year
      @company_index = Hash.new_nested Hash
      input_by_year = Hash.new_nested Array

      @input.each do |input_values, company, year|
        handle_unknowns input_values, company, year do
          input_by_year[year] << "{#{wl_single_answer_input input_values}}"
          add_company_index company, year, input_by_year[year].size - 1
        end
      end
      input_by_year
    end

    # Input in Wolfram Language expression to calculate
    # the value for one year and one company
    def wl_single_answer_input input_values
      input_values.map.with_index do |value, i|
        translate_input_value value, i
      end.join(",")
    end

    def translate_input_value value, index
      case value
      when Array
        result = value.map { |v| translate_input_value(v, index) }.join ","
        "{#{result}}"
      when "false"
        "False"
      when "nil"
        "null"
      when "Unknown"
        "\"Unknown\""
      else
        @input.type(index).in?(%i[number yearly_value]) ? value : "\"#{value}\""
      end
    end

    def add_company_index company, year, index
      @company_index[year.to_s][company] = index
    end
  end
end
