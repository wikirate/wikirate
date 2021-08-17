require "execjs"

module Formula
  # Calculate formula values using JavaScript
  class JavaScript < NestCalculator
    # coffeescript has the advantage of making sure the function _returns_ the value
    def compile
      ::CoffeeScript.compile full_coffee, bare: true
    end

    def compute _v, company_id, year
      computer[lookup_key(company_id, year)]
    end

    def boot
      ExecJS.compile(program).call "calcAll", input_hash
    end

    private

    def full_coffee
      <<~COFFEE
        calcAll = (obj) ->
          r = {}
          for key, val of obj
            r[key] = calc(val)
          r
        calc = (iN) ->
        #{prepended_coffee_formula}
      COFFEE
    end

    def lookup_key company_id, year
      "#{year}-#{company_id}"
    end

    # all inputs in the form of { year-company_id => values }
    def input_hash
      hash = {}
      each_input do |values, company_id, year|
        hash[lookup_key(company_id, year)] = values
      end
      hash
    end

    # adds spaces before each coffeescript line so the initial indentation is correct
    def prepended_coffee_formula
      coffee_formula.split(/[\r\n]+/).map { |l| "  #{l}" }.join "\n"
    end

    # replaces nests with inputs (which are actually array lookups, eg iN[0])
    def coffee_formula
      replace_nests { |index| input_name index }
    end

    # just weird enough that users aren't likely to use it...
    def input_name index
      "iN[#{index}]"
    end

    # def prepare_values values
    #   values.map.with_index do |val, index|
    #     ruby_value val, index
    #   end
    # end
    #
    # def ruby_value value, index
    #   case value
    #   when Array
    #     value.map { |v| ruby_value v, index }
    #   when "false"
    #     false
    #   when "nil"
    #     nil
    #   when "Unknown"
    #     value
    #   else
    #     numeric?(index) ? value.to_f : value
    #   end
    # end

    # def numeric? index
    #   @numeric ||= {}
    #   return @numeric[index] unless @numeric[index].nil?
    #   @numeric[index] = input.type(index).in? %i[number yearly_value]
    # end
  end
end
