module Formula
  class Calculator
    # Formula
    # # Case 1a: explict company
    #   Total[{{Jedi+deadliness|company:"Death Star"}}]'
    # Case 1b: explict company list
    #   Total[{{Jedi+deadliness|company:"Death Star", "SPECTRE"}}]'
    # Case 2: related companies
    #   Total[{{Jedi+deadliness|company:Related[Jedi+more evil=yes]}}]'
    #   Total[{{Jedi+deadliness|company:Related[Jedi+more evil>=6]}}]'
    #   Total[{{Jedi+deadliness|company:Related[Jedi+more evil>=6 &&
    # Commons+Supplied by=Tier 1 Supplier]}}]'
    #
    # 1. find all companies that have a relation with the required value
    # 2.
    class Input
      class CompanyOptionsProcessor < Array
        attr_reader :no_company_options

        def initialize company_options
          @no_company_options = true
          return if company_options.blank?
          company_options.each do |company_option|
            self << interpret_company_expr(company_option)
            @no_company_options = false
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

        def normalize_company_expr expr
          expr.sub("company:", "").strip
        end

        def interpret_company_expr expr
          return nil if expr.blank?
          expr = normalize_company_expr expr
          CompanyOptionParser.new expr
        end
      end
    end
  end
end
