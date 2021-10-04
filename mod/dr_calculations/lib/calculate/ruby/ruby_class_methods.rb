class Calculate
  class Ruby
    # class methods for ruby formulae
    module RubyClassMethods
      # Is this the right class for this formula?
      def supported_formula? formula
        apply %i[remove_functions remove_nests check_symbols], formula
      end

      def remove_functions formula, translated=false
        allowed = translated ? FUNCTIONS.values : FUNCTIONS.keys
        cleaned = formula.clone
        allowed.each do |word|
          cleaned = cleaned&.gsub word, ""
        end
        cleaned
        # matcher = translated ? FUNC_VALUE_MATCHER : FUNC_KEY_MATCHER
        # formula.gsub(/#{matcher}/,'')
      end

      def check_symbols formula
        symbols = SYMBOLS.map { |s| "\\#{s}" }.join
        formula =~ /^[\s\d#{symbols}]*$/
      end

      def apply methods, arg
        methods = Array.wrap methods

        methods.inject(arg) do |ret, method|
          send method, ret
        end
      end

      def function_re
        @function_re ||= /#{standard_function_re}|#{lookup_function_re}/
      end

      def arg_re
        /([^.]+)/
      end

      def standard_function_re
        /\[#{arg_re}\]\.flatten\.count/
      end

      def lookup_function_re
        lookup_functions = LOOKUPS.map { |key| FUNCTIONS[key] }
        /(#{lookup_functions.join '|'})\(#{arg_re}\)/
      end
    end
  end
end
