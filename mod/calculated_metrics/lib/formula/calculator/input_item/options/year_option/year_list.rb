module Formula
  class Calculator
    class InputItem
      module Options
        module YearOption
          # Handles a year option with a list as value, i.e. more than one years or
          # relative year separated by comma.
          #
          # Example:
          #    year: 1999, 2020
          #    year: 1999, 2001, -1
          #    year: -1, 0, 5
          module YearList
            def process_year_option
              list = year_option.split(",").map(&:to_i)
              @fixed = []
              @offsets = []
              list.each do |y|
                year?(y) ? @fixed << y : @offsets << y
              end
              return @fixed if @offsets.empty?

              proc do |year|
                list.map do |year_offset|
                  if year? year_offset
                    year_offset
                  else
                    year + year_offset
                  end
                end
              end
            end

            # @return an array of years for which values can be calculated out of the given
            #   list of years
            def translate_years years
              if @offsets.empty?
                (@fixed - years).empty? ? all_years : []
              else
                return [] if @fixed.present? && (@fixed - years).present?

                year_set = ::Set.new years
                years = years.sort

                # Example: offsets = [-3, -2, 1]
                #          years   = [2000, 2001, 2004]
                diffs = @offsets.sort
                first = diffs.shift
                diffs.map! { |n| n - first } # differences compared to the first offset
                # Example:  diffs = [1, 4]
                result = []
                0.upto(years.size - diffs.size) do |i|
                  # Example:
                  #      << 2000 - (-3) = 2003 is the only year for which the offsets
                  #                            match to the given years
                  result << years[i] - first if years_suit? years[i], diffs, year_set
                end
                result
              end
            end

            def years_suit? start_year, diffs, years
              diffs.all? do |d|
                years.include? start_year + d
              end
            end
          end
        end
      end
    end
  end
end
