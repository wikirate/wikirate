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
        def extended host_class
          host_class.validation_checks.concat @additional_checks
        end

        def self.extended host_class
          host_class.instance_variable_set("@additional_checks", [])
          host_class.define_singleton_method :add_validation_checks do |*more_checks|
            host_class.instance_variable_get("@additional_checks").concat more_checks
          end
        end
      end
    end
  end
end
