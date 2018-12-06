module Formula
  class Calculator
    class InputItem
      class YearlyVariable
        def search_value _year
          yearly_variable_value_cards.each do |vc|
            value_store.add card_id, vc.year, vc.content
          end
        end

        def yearly_variable_value_cards
          ::Card.search type_id: Card::YearlyValueID, left: { left_id: card_id }
        end
      end
    end
  end
end
