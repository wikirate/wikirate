module Formula
  class Calculator
    class InputItem
      module YearOption
        def initialize_decorator
          @processed_year_expr = interpret_year_option
        end

        def answer_query _year
          # since we need the values for all years to handle the year options,
          # there is no point in restricting the query to one year
          super(nil)
        end

        def value_for company, year
          values_for_all_years = values_by_year company
          apply_year_option values_for_all_years, year
        end

        def search_value _year
          super(nil)
        end

        # @param value_data [Array<Hash] for every input item a hash with values for every
        #   year
        # @param the year we want the input data for
        def apply_year_option value_data, year
          year = year.to_i

          ip = @processed_year_expr
          case ip
          when Integer
            year?(ip) ? value_data[ip] : value_data[year + ip]
          when Array
            ip.map { |year| value_data[year] }
          when Proc
            ip.call(year).map { |y| value_data[y] }
          else
            raise Card::Error, "illegal input processor type: #{ip.class}"
          end
        end

        private

        def normalize_year_option
          @year_option = @year_option.sub("year:", "").tr("?", "0").strip
        end

        def year? y
          y.is_a?(Integer) && y > 1000
        end

        def interpret_year_option
          return 0 if year_option.blank?
          normalize_year_option
          case year_option
          when /^[0?]$/     then 0
          when /^[+-]?\d+$/ then year_option.to_i
          when /,/          then year_list
          when /\.\./       then year_range
          end
        end

        def year_list
          list = year_option.split(",").map(&:to_i)
          return list if list.all? { |y| year? y }
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

        def year_range
          start, stop = year_option.split("..").map(&:to_i)
          if year?(start) && year?(stop)
            (start..stop).to_a
          elsif !year?(start) && !year?(stop)
            proc do |year|
              (year + start..year + stop).to_a
            end
          elsif !year?(start)
            proc do |year|
              (start..year + stop).to_a
            end
          else # = !year?(stop)
            proc do |year|
              (start..year + stop).to_a
            end
          end
        end
      end
    end
  end
end
