module Formula
  class Calculator
    class InputItem
      # Formula
      # # Case 1a: explict company
      #   Total[{{Jedi+deadliness|company:"Death Star"}}]'
      # Case 1b: explict company list
      #   Total[{{Jedi+deadliness|company:"Death Star", "SPECTRE"}}]'
      # Case 2: related companies
      #   Total[{{Jedi+deadliness|company:Related[Jedi+more evil=yes]}}]'
      #   Total[{{Jedi+deadliness|company:Related[Jedi+more evil>=6]}}]'
      #   Total[{{Jedi+deadliness|company:Related[Jedi+more evil>=6 &&
      # Commons+Supplied by=Tier 1 Supplier]}}]'
      #
      # 1. find all companies that have a relation with the required value
      # 2.
      module CompanyOption
        def initialize_decorator
          @processed_company_expr = interpret_company_option
        end


        def values object_company_ids, year
          query = { metric_id: card_id, company_id: object_company_ids, year: year.to_i }
          Answer.fetch(query).compact.map do |a|
            Answer.value_from_lookup a.value, type
          end
        end

        private

        def interpret_company_option
          case company_option
          when /^\s*Related\[([^]]+)\]\s*$/
            @company_option = $1
            extend CompanyRelated
          when /^[\w\s+\d]/
            extend CompanyFixed
          end
        end
      end
    end
  end
end
