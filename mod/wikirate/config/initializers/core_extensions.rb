# extend core Ruby object classes
module CoreExtensions
  # extend core String class
  module String
    def number?
      true if Float(self)
    rescue
      false
    end
  end
end

class String
  include CoreExtensions::String
end
