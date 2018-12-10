module Formula
  class Calculator
    class InputItem
      module CompanyOption
        # This modules handles a "Related" expressions in formulas like
        # Related[Jedi+more evil >= 6 && Commons+Supplied by=Tier 1 Supplier]
        module CompanyRelated
          def each_answer
            relations.each do |subject_company_id, year, object_company_ids|
              v = values object_company_ids, year
              next unless v.present?
              yield subject_company_id, year, v
            end
          end

          def years_and_values_for_each_company
            hash = {}
            each_answer do |sc_id, y, v|
              hash[sc_id] ||= [[],[]]
              hash[sc_id][0] << y
              hash[sc_id][1] << v
            end
            hash.each_pair do |c_id, (values, years)|
              yield c_id, values, years
            end
          end

          # @return array with triples
          #   [subject_company_id, year, Array<object_company_id>]
          #   Each of these relations satifies the "Related" condition in the formula
          #   At this point we haven't checked if the input metric has actually an answer
          #   for these object_companies
          def relations
            @relations ||=
              ActiveRecord::Base.connection.select_rows(sql).map do |sc_id, year, oc_ids|
                [sc_id, year, oc_ids.split("##").map(&:to_i)]
              end
          end

          def sql
            parse_expressions
            [RELATED_SELECT,
             join_sql(@exprs.size - 1),
             "WHERE (#{where_sql})",
             RELATED_GROUP_BY].flatten.compact.join " "
          rescue Expression::Error => _e
            # TODO: error handling
          end

          private

          def where_sql
            [metric_wheres, value_wheres,
             company_search_space_sql, year_search_space_sql].compact.join ") && ("
          end

          def join_sql count
            count.times.map { |no| related_join_sql no  }
          end

          def metric_wheres
            @exprs.map(&:metric_sql).join " && "
          end

          def value_wheres
            @exprs.inject(company_option) do |res, expr|
              expr.querify(res)
            end
          end

          def company_search_space_sql
            return unless search_space.company_ids?
            "(r0.subject_company_id IN (#{answer_candidates.company_ids.join ','})"
          end

          def year_search_space_sql
            return unless search_space.years?
            "(r0.year IN (#{answer_candidates.years.join ','})"
          end

          def parse_expressions
            @exprs =
              company_option.split(Expression::SPLIT_REGEX).map.with_index do |part, i|
                Expression.new part.strip.sub(/^\(*/, "").sub(/\)*$/, ""), i
              end
          end

          def related_join_sql no
            "JOIN relationships AS r#{no} "\
            "ON r0.object_company_id = r#{no}.object_company_id && "\
            "r0.subject_company_id = r#{no}.subject_company_id && "\
            "r0.year = r#{no}.year"
          end

          RELATED_SELECT = "SELECT r0.subject_company_id, r0.year, "\
                           "GROUP_CONCAT(r0.object_company_id SEPARATOR '##') "\
                           "FROM relationships AS r0".freeze
          RELATED_GROUP_BY = "GROUP BY r0.subject_company_id, r0.year"
        end
      end
    end
  end
end
