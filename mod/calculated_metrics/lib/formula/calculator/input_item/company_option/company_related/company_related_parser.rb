module Formula
  class Calculator
    class InputItem
      module CompanyOption
        module CompanyRelated
          # This modules handles a "Related" expressions in formulas like
          # Related[Jedi+more evil >= 6 && Commons+Supplied by=Tier 1 Supplier]
          class CompanyRelatedParser
            def initialize str, search_space
              @str = str
              @search_space = search_space
            end

            # @return array with triples
            #   [subject_company_id, year, Array<object_company_id>]
            #   Each of these relations satifies the "Related" condition in the formula
            #   At this point we haven't checked if the input metric has actually an answer
            #   for these object_companies
            def relations
              ActiveRecord::Base.connection.select_rows(sql).map do |sc_id, year, oc_ids|
                [sc_id, year, oc_ids.split("##").map(&:to_i).uniq]
              end
            end

            private

            def sql
              parse_expressions
              [RELATED_SELECT,
               join_sql(@conditions.size - 1),
               "WHERE (#{where_sql})",
               RELATED_GROUP_BY].flatten.compact.join " "
            rescue Condition::Error => _e
              # TODO: error handling
            end

            def where_sql
              [value_and_metric_wheres,
               company_search_space_sql, year_search_space_sql].compact.join ") && ("
            end

            def join_sql count
              count.times.map { |no| related_join_sql no + 1 }
            end

            # def metric_wheres
            #   @exprs.map(&:metric_sql).join " && "
            # end

            def value_and_metric_wheres
              @conditions.inject(@str) do |res, expr|
                expr.querify(res)
              end
            end

            def company_search_space_sql
              return unless @search_space.company_ids?

              "(r0.subject_company_id #{in_or_eq @search_space.company_ids})"
            end

            def year_search_space_sql
              return unless @search_space.years?

              "(r0.year #{in_or_eq @search_space.years})"
            end

            def in_or_eq vals
              if vals.size > 1
                "IN (#{vals.join ','})"
              else
                "= #{vals.first}"
              end
            end

            def parse_expressions
              @conditions =
                @str.split(Condition::SPLIT_REGEX).map.with_index do |part, i|
                  Condition.new part.strip.sub(/^\(*/, "").sub(/\)*$/, ""), i
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
end
