class Calculate
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
              send @translate, years.clone
            end

            private

            def year_option_type
              :"#{fixed_or_relative @start}_start_#{fixed_or_relative @stop}_end"
            end

            def fixed_or_relative config
              year?(config) ? :fixed : :relative
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
              tallying years, @start, @stop do |index|
                index.upto(years.size - 1) do |i|
                  break if i > index && years[i] != years[i - 1] + 1

                  tally! i
                end
              end
            end

            def relative_start_fixed_end years
              # 2..2001
              tallying years, @stop, @start do |index|
                index.downto(0) do |i|
                  break if i < index && years[i] != years[i + 1] - 1

                  tally! i
                end
              end
            end

            def tallying years, from, offset
              years.sort!
              index = years.index from

              @tally = []
              @tally_years = years
              @tally_offset = offset

              yield index if index
              @tally
            end

            def tally! index
              @tally.push @tally_years[index] - @tally_offset
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
              index = 0
              while index < years.size - seq_len
                index = scan_years years, index do |year, span|
                  yield year if span >= seq_len
                end
              end
            end

            def scan_years years, index
              scan_index = index + 1

              while applicable_index? scan_index, years
                yield years[scan_index], (scan_index - index)
                scan_index += 1
              end

              scan_index
            end

            def applicable_index? index, years
              index < years.size && years[index] == years[index - 1] + 1
            end
          end
        end
      end
    end
  end
end
