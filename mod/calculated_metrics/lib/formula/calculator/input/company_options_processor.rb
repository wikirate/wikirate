module Formula
  class Calculator
    class Input
      class CompanyOptionsProcessor < Array
        attr_reader :multi_year, :no_year_options

        def initialize company_options
          @fixed_companies = ::Set.new
          @no_company_options = true
          return if company_options.blank?
          company_options.each do |company_option|
            self << interpret_company_expr(company_option)
            next if (cur = last) == 0
            @multi_year = true
            @no_company_options = false
            @fixed_companies << cur if year?(cur)
          end
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

        def normalize_year_expr expr
          expr.sub("year:", "").tr("?", "0").strip
        end

        def year? y
          y.is_a?(Integer) && y > 1000
        end

        def interpret_company_expr expr
          return 0 if expr.blank?
          expr = normalize_year_expr expr

          case expr
          when /^[0?]$/ then 0
          when /^[+-]?\d+$/ then expr.to_i
          when /,/
            years = expr.split(",").map(&:to_i)
            year_list years
          when /\.\./ then
            start, stop = expr.split("..").map(&:to_i)
            year_range(start, stop)
          end
        end

        def year_list list
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

        def year_range start, stop
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
