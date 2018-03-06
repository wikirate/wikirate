# module for organizing Calculator and Input classes
module Formula
  def self.calculator_class formula
    [Translation, Ruby].find { |klass| klass.valid_formula? formula } || Wolfram
  end
end
