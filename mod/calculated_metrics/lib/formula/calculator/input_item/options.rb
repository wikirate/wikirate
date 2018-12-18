module Formula
  class Calculator
    class InputItem
      module Options
        def initialize_options
          extend CompanyOption if company_option?
          extend YearOption if year_option?
          extend UnknownOption if unknown_option?
          initialize_option
        end

        def initialize_option; end

        def year_option?
          year_option.present? && year_option != "0"
        end

        def company_option?
          company_option.present?
        end

        def unknown_option?
          unknown_option.present?
        end

        def year_option
          @year_option ||=
            normalize_year_option @input_values.year_options[@input_index]
        end

        def company_option
          @company_option ||=
            normalize_company_option @input_values.company_options[@input_index]
        end

        def unknown_option
          @unknown_option ||=
            normalize_unknown_option @input_values.unknown_options[@input_index]
        end

        def normalize_year_option option
          return unless option.present?

          option.sub("year:", "").tr("?", "0").strip
        end

        def normalize_company_option option
          return unless option.present?

          option.sub("company:", "").strip
        end

        def normalize_unknown_option option
          return unless option.present?

          option.sub("unknown:", "").strip.downcase.to_sym
        end
      end
    end
  end
end
