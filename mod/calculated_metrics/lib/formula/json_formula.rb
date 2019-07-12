module Formula
  # The common ground of Translatiosn and WikiRatings formula
  class JsonFormula < Calculator
    def to_lambda
      @parser.formula.downcase
    end

    # Is this the right class for this formula?
    def self.supported_formula? formula
      formula =~ /^\{[^{}]*\}$/
    end

    def safe_to_convert? expr
      self.class.supported_formula? expr
    end

    def safe_to_exec? _expr
      true
    end

    def exec_lambda expr
      JSON.parse expr
    rescue JSON::ParserError => _e
      @errors << "invalid #{self.class.name} formula #{expr}"
      false
    end
  end
end
