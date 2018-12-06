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

        def search_value _year
          value_data = @processed_company_expr.companies_and_years company_list.to_a

          new_ids = ::Set.new
          value_data.each do |subject_company_id, year, object_company_ids|
            v = values object_company_ids, year
            next unless v.present?
            new_ids.add subject_company_id
            store_value subject_company_id, year, v
          end
          company_list.update new_ids
        end

        def values object_company_ids, year
          query = { metric_id: card_id, company_id: object_company_ids, year: year.to_i }
          Answer.fetch(query).compact.map do |a|
            Answer.value_from_lookup a.value, type
          end
        end

        private

        def normalize_company_option
          @company_option = @company_option.sub("company:", "").strip
        end

        def interpret_company_option
          return nil if company_option.blank?
          normalize_company_option
          CompanyOptionParser.new @company_option
        end
      end
    end
  end
end
