module Formula
  class Calculator
    class InputItem
      module Options
        def initialize_options
          extend CompanyOption if company_option?
          extend YearOption if year_option?
          extend UnknownOption if unknown_option?
          extend NotResearchedOption if not_researched_option?
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

        def not_researched_option?
          not_researched_option.present?
        end

        Formula::Parser::OPTIONS.each do |opt|
          define_method "#{opt}_option" do
            instance_variable_get("@#{opt}_option") ||
              instance_variable_set("@#{opt}_option", normalized_option_value(opt))
          end
        end

        def normalized_option_value opt
          value = parser.send("#{opt}_option", @input_index)
          return unless value.present?
          try("normalize_#{opt}_option", value) || value
        end

        def normalize_year_option option
          option.tr("?", "0")
        end
      end
    end
  end
end
