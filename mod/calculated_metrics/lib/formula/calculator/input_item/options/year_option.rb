module Formula
  class Calculator
    class InputItem
      module Options
        # Handle year options for input items of formula
        # Examples:
        #    year: -1
        #    year: 2000..2004
        #    year: -4..0
        #    year: -4, 2
        #    year: 1999, 2001, -1
        module YearOption
          extend AddValidationChecks
          add_validation_checks :check_year_option

          def initialize_option
            super
            interpret_year_option
            processed_year_option
          end

          def check_year_option
            add_error "invalid year option: #{year_option}" unless interpret_year_option
          end

          def full_search
            values_by_year_for_each_company do |c_id, values_by_year|
              years = values_by_year.keys
              translate_years(years).each do |year|
                final_val = apply_year_option values_by_year, year
                store_value c_id, year, final_val
              end
            end
          end

          def processed_year_option
            @processed_year_option ||= process_year_option
          end

          def process_year_option
            year_option
          end

          # @param value_data [Array<Hash] for every input item a hash with values for every
          #   year
          # @param the year we want the input data for
          def apply_year_option value_data, year
            year = year.to_i

            ip = processed_year_option
            case ip
            when Integer
              year?(ip) ? value_data[ip] : value_data[year + ip]
            when Array
              ip.map { |y| value_data[y] }
            when Proc
              ip.call(year).map { |y| value_data[y] }
            else
              raise Card::Error, "illegal input processor type: #{ip.class}"
            end
          end

          private

          def all_years
            @all_years ||= Card.search(type_id: Card::YearID, return: :name)
                             .map(&:to_i).tap { |a| a.delete 0 }
          end

          def year? y
            y.is_a?(Integer) && y > 1000
          end

          def interpret_year_option
            case year_option
            when /^[-+]?\d+$/ then extend YearSingle
            when /^[-+]?[\d\s]+,[-+\d\s,]+$/ then extend YearList
            when /[-+]?\d+\.\.[-+]?\d+$/ then extend YearRange
            end
          end
        end
      end
    end
  end
end
