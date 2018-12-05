module Formula
  class Calculator
    class Input
      module YearOption
        attr_reader :multi_year, :no_year_options

        def initialize_decorator
          @processed_year_expr = interpret_year_option
          @multi_year = @processed_year_expr != 0
        end

        def answer_query _year
          # since we need the values for all years to handle the year options,
          # there is no point in restricting the query to one year
          super(nil)
        end

        def fetch_value year

        end


        # @param value_data [Array<Hash] for every input item a hash with values for every
        #   year
        # @param the year we want the input data for
        def run value_data, year
          year = year.to_i
          if @no_year_options
            return value_data.map { |values_by_year| values_by_year[year] }
          end

          map.with_index do |ip, i|
            case ip
            when Integer
              year?(ip) ? value_data[i][ip] : value_data[i][year + ip]
            when Array
              ip.map { |year| value_data[i][year] }
            when Proc
              ip.call(year).map { |y| value_data[i][y] }
            else
              raise Card::Error, "illegal input processor type: #{ip.class}"
            end
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
          normalize_year_expr
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
