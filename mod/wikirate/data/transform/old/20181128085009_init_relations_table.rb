# -*- encoding : utf-8 -*-

class InitRelationsTable < Cardio::Migration::Transform  def up
    Relationship.refresh_all
  end
end
