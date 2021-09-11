module GraphQL
  module Types
    class BaseEdge < Types::BaseObject
      # add `node` and `cursor` fields, as well as `node_type(...)` override
      include Types::Relay::EdgeBehaviors
    end
  end
end
