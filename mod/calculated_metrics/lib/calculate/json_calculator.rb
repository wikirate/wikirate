class Calculate
  # The common ground of Translations and WikiRatings formula
  class JsonCalculator < Calculator
    def compile
      @parser.formula
    end

    # Is this the right class for this formula?
    def self.supported_formula? formula
      formula =~ /^\{[^{}]*\}$/
    end

    def programmable? expr
      self.class.supported_formula? expr
    end

    def boot
      JSON.parse program
    rescue JSON::ParserError => _e
      @errors << "invalid #{self.class.name} formula #{program}"
      false
    end
  end
end
