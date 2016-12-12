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

  ::String.include_extension String

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

  ::Symbol.include_extension PersistentIdentifier
  ::Integer.include_extension PersistentIdentifier
end
