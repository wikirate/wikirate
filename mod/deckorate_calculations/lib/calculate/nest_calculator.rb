class Calculate
  # The common ground of Ruby and JavaScript formulae
  class NestCalculator < Calculator
    def programmable? expr
      @unsafe = expr
      safety_checks
      @errors.concat input.validate
      @errors.empty?
    end

    def safety_checks
      check_brackets
    end

    private

    def check_brackets
      brackets_balanced?(@unsafe.scan("{{").size, @unsafe.scan("{{").size, "}}") &&
        check_single_brackets
    end

    def brackets_balanced? open_cnt, close_cnt, close_char
      if open_cnt > close_cnt
        @errors << "syntax error: missing '#{close_char}'"
      elsif  open_cnt < close_cnt
        @errors << "syntax error: unexpected '#{close_char}'"
      end
      open_cnt == close_cnt
    end

    def check_single_brackets
      [["(", ")"], ["[", "]"], ["{", "}"]].each do |open, close|
        brackets_balanced? @unsafe.count(open), @unsafe.count(close), close
      end
    end
  end
end
