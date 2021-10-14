class Calculate
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
              process_year_option_list list
              @offsets.empty? ? @fixed : year_option_list_proc(list)
            end

            def process_year_option_list list
              list.each do |y|
                year?(y) ? @fixed << y : @offsets << y
              end
            end

            def year_option_list_proc list
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

            # @return an array of years for which values can be calculated out of
            #   the given list of years
            def translate_years years
              if @offsets.empty?
                translated_years_without_offsets years
              elsif not_all_fixed_years_present? years
                []
              else
                translate_nonstandard_years years
              end
            end

            def not_all_fixed_years_present? years
              @fixed.present? && (@fixed - years).present?
            end

            def translated_years_without_offsets years
              (@fixed - years).empty? ? all_years : []
            end

            def translate_nonstandard_years years
              year_set ||= ::Set.new years
              years = years.sort

              # Example: offsets = [-3, -2, 1]
              #          years   = [2000, 2001, 2004]
              diffs = @offsets.sort
              first = diffs.shift
              diffs.map! { |n| n - first } # differences compared to the first offset
              # Example:  diffs = [1, 4]
              up_to_years years, diffs, first, year_set
            end

            def up_to_years years, diffs, first, year_set
              0.upto(years.size - diffs.size).with_object([]) do |i, result|
                # Example:
                #      << 2000 - (-3) = 2003 is the only year for which the offsets
                #                            match to the given years
                year = years[i]
                result << year - first if years_suit? year, diffs, year_set
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
