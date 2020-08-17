fail "what?"

# extend core Ruby object classes
module CoreExtensions
  # extend core String class
  module String
    def number?
      true if Float(self)
    rescue StandardError
      false
    end

    def url?
      start_with?("http://", "https://")
    end

    # TODO: move to decko
    def card_id
      Card::Lexicon.id self
    end
  end
end

class String
  include CoreExtensions::String
end
