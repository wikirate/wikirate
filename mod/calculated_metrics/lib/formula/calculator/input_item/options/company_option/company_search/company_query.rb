module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            # Used if a "Related" expression is passed as company option
            # Example:
            #   {{ M1 | company: Related[M2 >= 6 && M3=Tier 1 Supplier] }}
            #
            # It makes the values for this input item independent of the output company
            # (since the answers for the companies of the company option are always used)
            class CompanyQuery
              include SqlHelper

              attr_reader :search_space

              def initialize str, search_space
                @str = str
                @search_space = search_space
              end

              def validate
                only_one_related
                parse_conditions
                init_conditions
                validate_conditions
              end

              def sql
                validate
                [@related_condition.select_sql,
                 join_sql,
                 where_sql,
                 @related_condition.group_by_sql].flatten.compact.join " "
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

              private

              def join_sql
                return unless join_sql_parts.present?

                join_sql_parts.join " "
              end

              def where_sql
                "WHERE (#{where_sql_parts.join ') && ('})"
              end

              def where_sql_parts
                [@related_condition.where_sql,
                 @answer_conditions.map(&:where_sql),
                 company_search_space_sql,
                 year_search_space_sql].flatten.compact
              end

              def join_sql_parts
                [@related_condition.join_sql,
                 @answer_conditions.map(&:join_sql)].flatten.compact
              end

              def company_search_space_sql
                return unless @search_space&.company_ids?

                "(#{@related_condition.subject_sql} #{in_or_eq @search_space.company_ids})"
              end

              def year_search_space_sql
                return unless @search_space&.years?

                "(r0.year #{in_or_eq @search_space.years})"
              end

              def parse_conditions
                head, related, tail = @str.partition(/Related\[[^\]]*\]/)
                @related_condition = related[/(?<=^Related\[).+(?=\])/]
                @answer_conditions =
                  "#{head}#{tail}".sub(/^\s*&&/, "").sub(/&&\s*$/, "")
                                  .split("&&").map(&:strip)
              end

              def init_conditions
                @related_condition = RelatedCondition.new @related_condition
                @answer_conditions.map!.with_index do |con, i|
                  AnswerCondition.new con, i
                end
              end

              def validate_conditions
                @related_condition.validate
                @answer_conditions.each(&:validate)
              end

              def only_one_related
                return unless @str.scan(/Related\[[^\]]*\]/).size > 1

                raise Condition::Error, "only one 'Related' expression allowed"
              end
            end
          end
        end
      end
    end
  end
end
