module GraphQL
  module Types
    module NodeType
      include Types::BaseInterface
      # Add the `id` field
      include Types::Relay::NodeBehaviors
    end
  end
end
