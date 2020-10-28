class Card
  # special error class for problems converting source to PDF
  #
  # we want "user error" here, because that gives us
  class SourceConversionError < Error::UserError
    class << self
      def view
        :conversion_error
      end
    end
  end
end