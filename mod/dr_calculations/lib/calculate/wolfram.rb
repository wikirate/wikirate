class Calculate
  class Wolfram < NestCalculator
    include Unknowns
    include Validation

    # INPUT_CAST = lambda { |val| val == 'Unknown' ? 'Unknown'.to_f }
    # To reduce the Wolfram Cloud calls the Wolfram calculator
    # calculates all values at once when it compiles the formula and saves
    # the result in @computer
    # Getting the value is just fetching the value from a hash
    def compute _input, company, year
      computer[year.to_s][@company_index[year.to_s][company]]
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

    def compile
      "Apply[(#{wl_formula})&,<| #{wl_input} |>,{2}]"
    end

    # @return Hash (parsed JSON from "Result" of body section)
    #   if there is an error, returns False and errors are added to @errors array

    # Sends a Wolfram language expression to the Wolfram cloud. Fetches and
    # validates the result.
    # @param [String] expr an expression in Wolfram language that returns json
    #   when evaluated in the Wolfram cloud
    # @return the parsed response
    def boot
      caller = Caller.new program
      caller.run
      if caller.errors.present?
        @errors += caller.errors
        nil
      else
        insert_unknown_results caller.results
      end
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

      input_values do |input_values, company, year|
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
        value_type(index) == :number ? value : "\"#{value}\""
      end
    end

    def value_type index
      input.input_list[index].type
    end

    def add_company_index company, year, index
      @company_index[year.to_s][company] = index
    end
  end
end
