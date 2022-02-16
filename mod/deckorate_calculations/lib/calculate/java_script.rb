require "execjs"

class Calculate
  # Calculate formula values using JavaScript
  class JavaScript < NestCalculator
    def formula_js_code
      read_file_in_mod "deckorate_calculations/assets/script/vendor/formula.js"
    end

    # coffeescript has the advantage of making sure the function _returns_ the value
    def compile
      ExecJS.compile full_javascript
    end

    def full_javascript
      [
        formula_js_code,
        region_json,
        ::CoffeeScript.compile(full_coffee, bare: true)
      ].join "\n"
    end

    def read_file_in_mod path_in_mod
      File.read File.expand_path("../../../../#{path_in_mod}", __FILE__)
    end

    # FIXME: should not be in this mod!!
    def region_json
      "wikirateRegion = #{read_file_in_mod 'wikirate_companies/lib/region.json'}"
    end

    def compute _v, company_id, year
      computer[lookup_key(company_id, year)]
    end

    def boot
      computer = {}
      # running in slices keeps JS from running out of memory
      value_hash.each_slice 5000 do |value_hash_slice|
        puts "calling with #{value_hash_slice.to_h}"
        computer.merge! program.call "calcAll", value_hash_slice.to_h
      end
      computer
    end

    def cast val
      val.number? ? val.to_f : val
    end

    private

    def full_coffee
      <<~COFFEE
        iloRegion = (region) ->
          regionLookup region, "ilo_region"
        country = (region) ->
          regionLookup region, "country"
        regionLookup = (region, field) ->
          entry = wikirateRegion[region]
          entry[field] if entry
        isKnown = (answer) ->
          answer != "Unknown"
        numKnown = (list) ->
          formulajs.COUNTIF list, "<>Unknown"
        anyKnown = (list) ->
          list.find isKnown
        addFormulaFunctions = (context) ->
          for key in Object.keys formulajs
            context[key] = formulajs[key]
        calcAll = (obj) ->
          r = {}
          for key, val of obj
            r[key] = calc(val)
          r
        calc = (iN) ->
          addFormulaFunctions this
        #{prepended_coffee_formula}
      COFFEE
    end

    def lookup_key company_id, year
      "#{year}-#{company_id}"
    end

    # all inputs in the form of { year-company_id => values }
    def value_hash
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
      (coffee_variables << formula).join "\n"
    end

    def coffee_variables
      input.input_list.map do |input_item|
        x = "#{input_item.options[:name]} = #{input_name input_item.input_index}"
        puts x
        x
      end
    end


    # just weird enough that users aren't likely to use it...
    def input_name index
      "iN[#{index}]"
    end
  end
end
