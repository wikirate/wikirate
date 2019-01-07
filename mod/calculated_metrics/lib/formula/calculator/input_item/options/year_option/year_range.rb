module Formula
  class Calculator
    class InputItem
      module Options
        module YearOption
          # Handles a year option with a range as value
          # Examples:
          #    year: 1999..2020
          #    year: 1999..-1
          #    year: -4..0
          module YearRange
            def process_year_option
              @start, @stop = year_option.split("..").map(&:to_i)
              if year?(@start) && year?(@stop)
                @translate = :fixed_start_fixed_end
                (@start..@stop).to_a
              elsif !year?(@start) && !year?(@stop)
                @translate = :relative_start_relative_end
                proc do |year|
                  (year + @start..year + @stop).to_a
                end
              elsif !year?(@start)
                @translate = :relative_start_fixed_end
                proc do |year|
                  (year + @start..@stop).to_a
                end
              else # = !year?(stop)
                @translate = :fixed_start_relative_end
                proc do |year|
                  (@start..year + @stop).to_a
                end
              end
            end

            def fixed_start_fixed_end years
              # 2000..2010
              (processed_year_option - years).empty? ? all_years : []
            end

            def fixed_start_relative_end years
              # 2000..-1
              years = years.sort
              index = years.index @start
              return [] unless index

              [].tap do |result|
                index.upto(years.size - 1) do |i|
                  break if i > index && years[i] != years[i - 1] + 1
                  result.push years[i] - @stop
                end
              end
            end

            def relative_start_fixed_end years
              # 2..2001
              years = years.sort
              index = years.index @stop
              return [] unless index

              [].tap do |result|
                index.downto(0) do |i|
                  break if i < index && years[i] != years[i + 1] - 1
                  result.push years[i] - @start
                end
              end
            end

            def relative_start_relative_end years
              # -4..-1
              years = years.sort
              seq_len = @stop - @start
              i = 0
              [].tap do |result|
                while i < years.size - seq_len
                  j = i + 1
                  while j < years.size && years[j] == years[j - 1] + 1
                    result << years[j] - @stop if j - i >= seq_len
                    j += 1
                  end
                  i = j
                end
              end
            end

            # @return an array of years for which values can be calculated out of the given
            #   list of years
            def translate_years years
              send @translate, years
            end
          end
        end
      end
    end
  end
end
