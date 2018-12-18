module Formula
  class Calculator
    class InputItem
      # Used for input items with invalid cardtype
      class InvalidInputItem < InputItem
        def validate
          [
            "#{@input_card.name} can't be used in a formula." \
            "#{@input_card.type} is not a valid type"
          ]
        end
      end
    end
  end
end
