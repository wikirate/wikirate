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

  # methods for codenames and numerical ids
  module PersistentIdentifier
    def card
      Card[self]
    end

    def cardname
      Card.quick_fetch(self).cardname
    end

    def name
      Card.quick_fetch(self).name
    end
  end
end

class String
  include CoreExtensions::String
end

class Symbol
  include CoreExtensions::PersistentIdentifier
end

class Integer
  include CoreExtensions::PersistentIdentifier
end
