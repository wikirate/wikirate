module Formula
  class Calculator
    class InputItem
      module CompanyOption
        # This modules handles a "Related" expressions in formulas like
        # Related[Jedi+more evil >= 6 && Commons+Supplied by=Tier 1 Supplier]
        module CompanyRelated
          include CompanyDependentInput

          def each_answer
            relations.each do |subject_company_id, year, object_company_ids|
              v = values_from_db object_company_ids, year
              next unless v.present?
              yield subject_company_id, year, v
            end
          end

          def values_by_year_for_each_company
            hash = {}
            each_answer do |sc_id, y, v|
              hash[sc_id] ||= {}
              hash[sc_id][y] = v
            end
            hash.each_pair do |c_id, v_by_y|
              yield c_id, v_by_y
            end
          end

          # @return array with triples
          #   [subject_company_id, year, Array<object_company_id>]
          #   Each of these relations satifies the "Related" condition in the formula
          #   At this point we haven't checked if the input metric has actually an answer
          #   for these object_companies
          def relations
            @relations ||=
              CompanyRelatedParser.new(company_option, search_space).relations
          end
        end
      end
    end
  end
end
