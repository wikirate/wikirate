module CoreExtensions
  module String
    def number?
      true if Float(self)
    rescue
      false
    end
  end
end
