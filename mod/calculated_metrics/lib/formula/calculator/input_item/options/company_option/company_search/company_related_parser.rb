module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            # This modules handles a "Related" expressions in formulas like
            # Related[Jedi+more evil >= 6 && Commons+Supplied by=Tier 1 Supplier]
            class CompanyRelatedParser
              def initialize str, search_space
                @str = str
                raise Condition::Error, "empty relation" if @str.blank?

                @search_space = search_space
              end

              # @return array with triples
              #   [subject_company_id, year, Array<object_company_id>]
              #   Each of these relations satifies the "Related" condition in the formula
              #   At this point we haven't checked if the input metric has actually
              #   an answer for these object_companies
              def relations
                ActiveRecord::Base.connection.select_rows(sql)
                                  .map do |sc_id, year, oc_ids|
                  [sc_id, year, oc_ids.split("##").map(&:to_i).uniq]
                end
              end

              # raises Condition::Error if something is wrong
              def validate
                parse_expressions
              end

              private

              def sql
                parse_expressions
                [related_select,
                 join_sql(@conditions.size - 1),
                 "WHERE (#{where_sql})",
                 related_group_by].flatten.compact.join " "
              end

              def where_sql
                [value_and_metric_wheres,
                 company_search_space_sql, year_search_space_sql].compact.join ") && ("
              end

              def join_sql count
                return unless count.positive? && and_chain?

                Array.new(count) { |i| related_join_sql i + 1 }
              end

              def value_and_metric_wheres
                @conditions.inject(@str) do |res, expr|
                  expr.querify(res)
                end
              end

              def company_search_space_sql
                return unless @search_space&.company_ids?

                "(#{subject_sql 0} #{in_or_eq @search_space.company_ids})"
              end

              def year_search_space_sql
                return unless @search_space&.years?

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
                validate_logic
                only_one_related
                @conditions =
                  @str.split(Condition::SPLIT_REGEX).map.with_index do |part, i|
                    table_index = and_chain? ? i : 0
                    Condition.new part.strip.sub(/^\(*/, "").sub(/\)*$/, ""), table_index
                  end
              end

              def only_one_related
                return unless @str.scan("Related\[[^\]]*\]").size > 1
                raise "only one 'Related' expression allowed"
              end


              def additional_restrictions
                @str.gsub(/Related\[[^\]]*\]/, "")
                return unless @str.include? "&&"
                @str.split("&&")
              end

              # only "&&"s
              def and_chain?
                @and_chain = @str.include?("&&") if @and_chain.nil?
                @and_chain
              end

              def validate_logic
                return unless @str.include?("&&") && @str.include?("||")
                raise Condition::Error, "mix of '&&' and '||' is not supported, yet"
              end

              def object_sql i
                @conditions[i].object_sql
              end

              def subject_sql i
                @conditions[i].subject_sql
              end

              def related_join_sql join_cnt
                "LEFT JOIN relationships AS r#{join_cnt} "\
                "ON #{object_sql 0} = #{object_sql join_cnt} && "\
                "#{subject_sql 0} = #{subject_sql join_cnt} && "\
                "r0.year = r#{join_cnt}.year"
              end

              def related_select
                "SELECT #{subject_sql 0}, r0.year, "\
                           "GROUP_CONCAT(#{object_sql 0} SEPARATOR '##') "\
                           "FROM relationships AS r0"
              end

              def related_group_by
                "GROUP BY #{subject_sql 0}, r0.year"
              end
            end
          end
        end
      end
    end
  end
end
