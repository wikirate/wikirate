class Card
  # special class for PDF conversion failures
  class SourceConversionError < Error
    class << self
      def view
        :conversion_error
      end
    end
  end
end
