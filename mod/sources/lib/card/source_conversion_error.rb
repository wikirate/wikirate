class Card
  class SourceConversionError < Error
    class << self
      def status_code
        500
      end

      def view
        :conversion_error
      end
    end
  end
end