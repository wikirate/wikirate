# module for organizing Calculator and Input classes
module Formula
  def self.calculator_class formula
    [Translation, Ruby].find { |klass| klass.supported_formula? formula } || Wolfram
  end
end
