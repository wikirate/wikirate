module Formula
  class Calculator
    class InputItem
      # When included then validation checks can be added by other modules
      # using the API provided by {AddValidationChecks}
      # The #validate method runs all those checks.
      module ValidationChecks
        def self.included host_class
          host_class.instance_variable_set("@validation_checks", [])
          host_class.define_singleton_method(:validation_checks) do
            host_class.instance_variable_get("@validation_checks")
          end
          host_class.define_method(:validation_checks) { host_class.validation_checks }
          host_class.define_method(:clear_validation_checks) do
            host_class.instance_variable_set("@validation_checks", [])
          end
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
