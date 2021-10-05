class Calculate
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
        #    year: latest
        #    year: all
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

          def processed_year_option
            @processed_year_option ||= process_year_option
          end

          def process_year_option
            year_option
          end

          # @param answer_hash [Hash] for every input item a hash with values
          #   for every year
          # @param year [Integer]the year we want the input data for
          def apply_year_option answer_hash, year
            ip = processed_year_option
            method = "apply_#{ip.class.to_s.downcase}_year_option"
            illegal_input_processor! ip unless respond_to? method

            send method, answer_hash, ip, year.to_i
          end

          def illegal_input_processor! ip
            raise Card::Error, "illegal input processor type: #{ip.class}"
          end

          def apply_integer_year_option answer_hash, ip, year
            year?(ip) ? answer_hash[ip] : answer_hash[year + ip]
          end

          def apply_array_year_option answer_hash, ip, year
            input_answers = ip.map { |y| answer_hash[y] }
            consolidated_input_answer input_answers, year
          end

          def apply_proc_year_option answer_hash, ip, year
            apply_array_year_option answer_hash, ip.call(year), year
          end

          def apply_symbol_year_option answer_hash, ip, year
            case ip
            when :all
              consolidated_input_answer answer_hash.values, year
            when :latest
              answer_hash[answer_hash.keys.max]
            else
              raise Card::Error, "unknown year Symbol: #{ip}"
            end
          end

          def restrict_years_in_query?
            false
          end

          private

          def all_years
            @all_years ||= Card::Set::Type::Year.all_years.map(&:to_i).tap do |a|
              a.delete 0
            end
          end

          def year? year
            year.is_a?(Integer) && year > 1000
          end

          def interpret_year_option
            case year_option
            when /^[-+]?\d+$/ then extend YearSingle
            when /^[-+]?[\d\s]+,[-+\d\s,]+$/ then extend YearList
            when /[-+]?\d+\.\.[-+]?\d+$/ then extend YearRange
            when /^all$/ then extend YearAll
            when /^latest$/ then extend YearLatest
            end
          end
        end
      end
    end
  end
end
