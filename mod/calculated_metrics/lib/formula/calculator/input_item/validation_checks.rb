module Formula
  class Calculator
    class InputItem
      # When included then validation checks can be added by other modules
      # using the API provided by {AddValidationChecks}
      # The #validate method runs all those checks.
      module ValidationChecks
        module ClassMethods
          def validation_checks
            @validation_checks ||= []
          end

          def add_validation_checks *more_checks
            validation_checks.concat more_checks
          end
        end

        def self.included host_class
          host_class.extend ClassMethods
          host_class.instance_variable_set("@validation_checks", [])
        end

        def validation_checks
          @val_checks ||= self.class.validation_checks.clone
        end

        # @return [Array] error messages if invalid; empty array if valid
        def validate
          @errors = []
          validation_checks.map { |check| send check }
          @errors
        end

        def add_error message
          @errors << message
        end
      end
    end
  end
end
