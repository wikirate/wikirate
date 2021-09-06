require "execjs"

class Calculate
  # Calculate formula values using JavaScript
  class JavaScript < NestCalculator
    # coffeescript has the advantage of making sure the function _returns_ the value
    def compile
      ExecJS.compile ::CoffeeScript.compile(full_coffee, bare: true)
    end

    def compute _v, company_id, year
      computer[lookup_key(company_id, year)]
    end

    def boot
      computer = {}
      # running in slices keeps JS from running out of memory
      input_hash.each_slice 5000 do |input_hash_slice|
        computer.merge! program.call "calcAll", input_hash_slice.to_h
      end
      computer
    end

    private

    def full_coffee
      <<~COFFEE
        isKnown = (answer) ->
          answer != "Unknown"
        numKnown = (list) ->
          list.filter(isKnown).length
        anyKnown = (list) ->
          list.find isKnown
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
      input_values do |values, company_id, year|
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
  end
end
