module Formula
  def calculator_class content
    [Translation, Ruby].find(klass) { klass.valid_formula? content } || Wolfram
  end
end
