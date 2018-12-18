module Formula
  class Calculator
    class InputItem
      # Provides API to add additional validation checks to a class that includes
      # {ValidationChecks}.
      #
      # Example:
      #     extend AddValidationChecks
      #     add_validation_checks :additional_check
      #
      #     def additional_check
      #       add_error "always bad"
      #     end
      module AddValidationChecks
        def add_validation_checks *more_checks
          define_method :validation_checks do
            super().concat more_checks
          end
        end
      end
    end
  end
end
