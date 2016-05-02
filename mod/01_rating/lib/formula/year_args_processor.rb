class Formula
  class YearArgsProcessor < Array
    attr_reader :multi_year
    def initialize content
      content.scan(/\{\{(?<metric>[^|}]+)(?:\|(?<year>[^}]*))?\}\}/) do
      |match|
        self <<
          if $~[:year]
            interpret_year_expr normalize_year_expr($~[:year])
          else
            0
          end
        if (cur = self.last) != 0
          @multi_year = true
          @fixed_years << cur if year?(cur)
        end
      end
    end

    def run value_data, year
      map.with_index do |ip, i|
        case ip
        when Integer
          year?(ip) ? value_data[i][ip] : value_data[i][year + ip]
        when Array
          ip.map { |year| data[i][year] }
        when Proc
          ip.call(year).map { |y| value_data[i][y] }
        else
          fail Card::Error, "illegal input processor type: #{ip.class}"
        end
      end
    end

    private

    def normalize_year_expr expr
      expr.sub('year:','').tr('?', '0').strip
    end

    def year? y
      y.is_a?(Integer) && y > 1000
    end

    def interpret_year_expr expr
      case expr
      when /^[0?]$/ then 0
      when /^[+-]?\d+$/ then expr.to_i
      when /,/
        years = expr.split(',').map(&:to_i)
        year_list years
      when /\.\./ then
        start, stop = expr.split('..').map(&:to_i)
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
          (year+start..year+stop).to_a
        end
      elsif !year?(start)
        proc do |year|
          (year+start..stop).to_a
        end
      else
        proc do |year|
          (year..year+stop).to_a
        end
      end
    end
  end
end
