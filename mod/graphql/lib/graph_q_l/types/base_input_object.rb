module GraphQL
  module Types
    class BaseInputObject < Schema::InputObject
      argument_class Types::BaseArgument
    end
  end
end
