module GraphQL
  module Types
    class BaseField < Schema::Field
      argument_class Types::BaseArgument
    end
  end
end
