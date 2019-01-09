module Formula
  class Calculator
    class InputItem
      module Options
        module CompanyOption
          # Used if a "Related" expression is passed as company option
          # Example:
          #   {{ M1 | company: Related[M2 >= 6 && M3=Tier 1 Supplier] }}
          #
          # It makes the values for this input item independent of the output company
          # (since the answers for the companies of the company option are always used)
          class CompanyQuery
            def initialize str, search_space

            end

            def conditions
              head, related, tail = @str.partition(/Related\[[^\]]*\]/)
              related_arg = related[/(?<=^Related\[).+(?=\])/]
              related_condition = CompanyRelatedParser.new related_arg, search_space
              (head.strip.split("&&") + tail.strip.split("&&")).each do |cond|
                Condition.new
              end
            end


            def sql

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
end
