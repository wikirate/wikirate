module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          module CompanySearch
            # This class handles a "Related" expression for a company option
            # Related[Jedi+more evil >= 6 && Commons+Supplied by=Tier 1 Supplier]
            class RelatedCondition
              include SqlHelper

              def initialize str
                @str = str
                raise Condition::Error, "empty relation" if @str.blank?

                if and_chain?
                  extend AndChain
                elsif or_chain?
                  extend OrChain
                end
              end

              # raises Condition::Error if something is wrong
              def validate
                parse
              end

              def parse
                validate_logic
                @conditions = []
                @str.split(Condition::SPLIT_REGEX).map.with_index do |part, i|
                  add_condition part.strip.sub(/^\(*/, "").sub(/\)*$/, ""), i
                end
                extend SingleInverse if @conditions.one? && any_inverse?
              end

              def add_condition str, index
                @conditions << Condition.new(str, index)
              end

              def select_sql
                <<-SQL.strip_heredoc
                  SELECT #{subject_sql}, r0.year,
                  GROUP_CONCAT(#{object_sql} SEPARATOR '##')
                  FROM #{select_from_sql}
                SQL
              end

              def select_from_sql
                "relationships AS r0"
              end

              def group_by_sql
                "GROUP BY #{subject_sql}, r0.year"
              end

              def where_sql
                @conditions.first.where_sql
              end

              def join_sql; end

              def object_sql
                "r0.object_company_id"
              end

              def subject_sql
                "r0.subject_company_id"
              end

              private

              # only "&&"s
              def and_chain?
                @and_chain = @str.include?("&&") if @and_chain.nil?
                @and_chain
              end

              # only "||"s
              def or_chain?
                @or_chain = @str.include?("||") if @or_chain.nil?
                @or_chain
              end

              def any_inverse?
                @conditions.any?(&:inverse?)
              end

              def metric_ids
                @conditions.reject(&:inverse?).map(&:metric_id)
              end

              def inverse_metric_ids
                @conditions.select(&:inverse?).map(&:metric_id)
              end

              def validate_logic
                return unless @str.include?("&&") && @str.include?("||")

                raise Condition::Error, "mix of '&&' and '||' is not supported, yet"
              end
            end
          end
        end
      end
    end
  end
end
