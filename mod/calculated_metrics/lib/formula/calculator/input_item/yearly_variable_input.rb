module Formula
  class Calculator
    class InputItem
      class YearlyVariable
        def before_full_search
          @value_store = ValueStore.new false
        end

        def after_full_search
          answer_candidates.update nil, years_with_values, mandatory?
        end

        def each_answer
          value_cards.each do |value_card|
            yield nil, value_card.year, value_card.content
          end
        end

        def mandatory?
          false # don't use yearly variables to reduce company search space
        end

        def store_value _company_id, year, value
          value_store.add year, value
        end

        def value_store
          @value_store ||= ValueStore.new false
        end

        def value_cards
          ::Card.search value_cards_query
        end

        def value_cards_query
          query = { type_id: Card::YearlyValueID, left: { left_id: card_id } }
          # TODO: restrict query to year search space
          # query[:left][:right] = search_space.years if search_space.years?
          query
        end
      end
    end
  end
end
