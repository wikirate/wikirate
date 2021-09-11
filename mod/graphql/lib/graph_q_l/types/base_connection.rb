module GraphQL
  module Types
    class BaseConnection < Types::BaseObject
      # add `nodes` and `pageInfo` fields, as well as `edge_type(...)` and `node_nullable(...)` overrides
      include Types::Relay::ConnectionBehaviors
    end
  end
end
