module Formula
  class Calculator
    class InputItem
      class YearlyVariable
        def value_fetch
          input_yearly_value_cards(card_id).each do |vc|
            @value_store.add card_id, vc.year, vc.content
          end
        end

        def input_yearly_value_cards yearly_variable_id
          ::Card.search type_id: Card::YearlyValueID,
                        left: { left_id: yearly_variable_id }
        end
      end
    end
  end
end
