# -*- encoding : utf-8 -*-

class InitRelationsTable < Cardio::Migration
  def up
    Relationship.refresh_all
  end
end
