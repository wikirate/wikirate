module GraphQL
  module Types
    class BaseUnion < Schema::Union
      edge_type_class(Types::BaseEdge)
      connection_type_class(Types::BaseConnection)
    end
  end
end
