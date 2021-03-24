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
              process_year_option_type year_option_type
            end

            # @return an array of years for which values can be calculated out of the
            #   given list of years
            def translate_years years
              send @translate, years
            end

            private

            def year_option_type
              if year?(@start) && year?(@stop)
                :fixed_start_fixed_end
              elsif !year?(@start) && !year?(@stop)
                :relative_start_relative_end
              elsif !year?(@start)
                :relative_start_fixed_end
              else
                :fixed_start_relative_end
              end
            end

            def process_year_option_type option
              @translate = option
              send "process_#{option}"
            end

            def process_fixed_start_fixed_end
              (@start..@stop).to_a
            end

            def process_relative_start_relative_end
              proc do |year|
                (year + @start..year + @stop).to_a
              end
            end

            def process_relative_start_fixed_end
              proc do |year|
                (year + @start..@stop).to_a
              end
            end

            def process_fixed_start_relative_end
              proc do |year|
                (@start..year + @stop).to_a
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
              [].tap do |result|
                each_rsre_year years.sort, (@stop - @start) do |year|
                  result << year - @stop
                end
              end
            end

            def each_rsre_year years, seq_len
              i = 0
              while i < years.size - seq_len
                j = i + 1
                while next_year_index? j, years
                  yield years[j] if j - i >= seq_len
                  j += 1
                end
                i = j
              end
            end

            def next_year_index? index, years
              index < years.size && years[index] == years[index - 1] + 1
            end
          end
        end
      end
    end
  end
end
