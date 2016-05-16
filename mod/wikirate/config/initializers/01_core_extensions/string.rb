module CoreExtensions
  module String
    def number?
      self =~ /^[-+]?\d+(?:[,.]\d+)?$/
    end
  end
end