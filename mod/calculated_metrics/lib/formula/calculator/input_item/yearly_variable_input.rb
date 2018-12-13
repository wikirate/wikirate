module Formula
  class Calculator
    class InputItem
      # Instances of {YearlyVariable} represent input items that refer to a yearly
      # variable
      # It uses the cards table to find values.
      # TODO: support year and company options
      class YearlyVariableInput < InputItem
        include CompanyIndependentInput

        delegate :with_full_year_space, to: :search_space

        def each_answer
          value_cards.each do |value_card|
            yield nil, value_card.year.to_i, value_card.content
          end
        end

        def values_by_year_for_each_company
          v_by_y =
            with_full_year_space do
              value_cards.each_with_object({}) { |vc, h| h[vc.year.to_i] = vc.content }
            end
          yield nil, v_by_y
        end

        # used for CompanyOption
        def values_from_db company_ids, year
          query = value_cards_query
          query[:left][:right] = { name: year }
          Card.search(query).map(&:content) * company_ids.size
        end

        def years_from_db _company_ids
          value_cards.map { |vc| vc.year.to_i }
        end

        def value_cards
          ::Card.search value_cards_query
        end

        def value_cards_query all_years: false
          query = { type_id: Card::YearlyValueID, left: { left_id: card_id } }
          if search_space.years? && !all_years
            query[:left][:right] = { name: ["in", search_space.years.to_a].flatten }
          end
          query
        end
      end
    end
  end
end
