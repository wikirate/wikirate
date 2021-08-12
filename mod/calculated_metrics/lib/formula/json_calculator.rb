module Formula
  # The common ground of Translations and WikiRatings formula
  class JsonCalculator < Calculator
    def build_executable
      @parser.formula
    end

    # Is this the right class for this formula?
    def self.supported_formula? formula
      formula =~ /^\{[^{}]*\}$/
    end

    def safe_to_convert? expr
      self.class.supported_formula? expr
    end

    def execute
      JSON.parse executable
    rescue JSON::ParserError => _e
      @errors << "invalid #{self.class.name} formula #{executable}"
      false
    end
  end
end
