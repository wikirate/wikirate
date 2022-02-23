class Calculate
  class Calculator
    class InputItem
      # Methods to handle nest option for a metric variable in a formula.
      # For every supported option there is a module which take cares of that option.
      module Options
        # note: these modules are included in InputItem
        # (calling extend from an instance is like calling include from a class)
        def initialize_options
          extend CompanyOption if option? :company
          extend YearOption if year_option?
          extend UnknownOption
          extend NotResearchedOption if option? :not_researched
          initialize_option
        end

        def initialize_option; end

        def year_option?
          option?(:year) && option(:year) != "0"
        end

        def option? opt
          @options[opt].present?
        end

        def option opt
          return unless (value = @options[opt]).present?

          try("normalize_#{opt}_option", value) || value
        end

        def normalize_year_option option
          option.tr "?", "0"
        end
      end
    end
  end
end
