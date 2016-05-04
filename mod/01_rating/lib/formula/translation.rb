module Formula
  class Translation < Calculator
    def get_value input, _company, _year
      if input.size > 1
        fail Card::Error,
             'translate formula with more than one metric involved'
      end
      @executed_lambda[input.first.to_s.downcase]
    end

    def to_lambda
      @formula.content.downcase
    end

    def self.valid_formula? formula
      formula =~ /^\{[^{}]*\}$/
    end

    protected

    def year_options
      nil
    end

    def exec_lambda expr
      JSON.parse expr
    end

    def safe_to_exec? expr
      true
    end
  end
end