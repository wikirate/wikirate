require "execjs"

class Calculate
  # Calculate formula values using JavaScript
  class JavaScript < Calculator
    def formula_js_code
      read_js_file "vendor/formula.js"
    end

    # coffeescript has the advantage of making sure the function _returns_ the value
    def program
      @program ||= ExecJS.compile full_javascript
    end

    def full_javascript
      [
        "deckorate = {};",
        formula_js_code,
        region_json,
        ::CoffeeScript.compile(full_coffee, bare: true)
      ].join "\n"
    end

    def read_js_file file_in_script
      read_file_in_mod "deckorate_calculations/assets/script/#{file_in_script}"
    end

    def read_file_in_mod path_in_mod
      File.read File.expand_path("../../../../#{path_in_mod}", __FILE__)
    end

    # regenerate with https://wikirate.org/region/lookup.json
    #
    # FIXME: should not be in this mod!!
    def region_json
      file_content = read_file_in_mod "wikirate_companies/public/region.json"
      "deckorate.region = #{file_content}"
    end

    def compute _v, company_id, year
      computer[lookup_key(company_id, year)]
    end

    def boot
      computer = {}
      # running in slices keeps JS from running out of memory
      function = "_calculateAll"
      value_hash.each_slice 5000 do |value_hash_slice|
        # puts "calling with #{value_hash_slice.to_h}"
        computer.merge! program.call(function, value_hash_slice.to_h)
      end
      computer
    end

    def cast val
      val.number? ? val.to_f : val
    end

    def programmable? expr
      @unsafe = expr
      @errors.concat input.validate
      @errors.empty?
    end

    def ready?
      return false unless programmable? formula
      @computer ||= safely_boot
      @errors.empty?
    end

    private

    def full_coffee
      read_js_file("calculator.js.coffee") + prepended_coffee_formula
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
        # puts x
        x
      end
    end

    def safely_boot
      boot unless @errors.any?
    rescue StandardError => e
      @errors << e.message
    end

    # just weird enough that users aren't likely to use it...
    def input_name index
      "inputList[#{index}]"
    end
  end
end
