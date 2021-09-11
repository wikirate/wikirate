module GraphQL
  module Types
    class PostType < Types::BaseObject
      field :title, String, null: true
      field :rating, Integer, null: true
    end
  end
end
