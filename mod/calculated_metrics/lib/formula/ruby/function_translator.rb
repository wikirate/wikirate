module Formula
  class Ruby < NestFormula
    # Translates Wolfram Language function calls to ruby code
    class FunctionTranslator
      FUNC_KEY_MATCHER = FUNCTIONS.keys.join("|").freeze

      class SyntaxError < StandardError; end

      class << self
        # @param [String] formula the formula to translate
        # @param [Integer] offset were we are in the original formula.
        #   only used for error messages
        # @return [String] Wolfram functions calls in formula replaced
        #   with ruby method calls
        def translate formula, offset=0
          with_next_match formula do |replacement, pos, i_arg_start|
            arg, rest = translate_after_match formula, offset, i_arg_start
            [formula[0, pos], "[#{arg}].flatten.#{replacement}", rest].join
          end
        end

        def with_next_match part
          return unless part.present?

          match = part.match FUNC_KEY_MATCHER
          return part unless match

          yield FUNCTIONS[match[0]], match.begin(0), match.end(0)
        end

        def tr_part formula, offset, start, stop=-1
          translate formula[start..stop], offset + start
        end

        # Translate the part right after a function name match.
        # We divide that part into the argument for the function and the rest
        # and translate both separately
        # @param formula [String]
        # @param offset [Integer] where are we in the whole formula
        # @param arg_start [Integer] position of opening '['
        # @return [String, String] the translated argument and the translated rest
        def translate_after_match formula, offset, arg_start
          arg_end = arg_end arg_start, formula, offset
          [tr_part(formula, offset, arg_start + 1, arg_end - 1),
           tr_part(formula, offset, arg_end + 1)]
        end

        def syntax_error type, pos
          pos += 1 # 1-based index in error message
          message =
            case type
            when :no_closing_bracket
              "invalid formula: no closing ']' found for '[' at #{pos}"
            when :no_opening_bracket
              "invalid formula: expected '[' at #{pos}"
            else
              "invalid formula: syntax error at #{pos}"
            end
          raise SyntaxError, message
        end

        private

        def arg_end arg_start, formula, offset
          if formula[arg_start] != "["
            syntax_error :no_opening_bracket, offset + arg_start
          end
          closing_bracket_index(arg_start + 1, formula) ||
            syntax_error(:no_closing_bracket, offset + arg_start)
        end

        def closing_bracket_index start, formula
          br_cnt = 1 # bracket count
          formula[start..-1].each_char.with_index do |char, j|
            case char
            when "[" then br_cnt += 1
            when "]" then br_cnt -= 1
            end
            return j + start if br_cnt.zero?
          end
          nil
        end
      end
    end
  end
end
