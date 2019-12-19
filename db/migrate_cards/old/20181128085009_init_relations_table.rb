# -*- encoding : utf-8 -*-

class InitRelationsTable < Card::Migration
  def up
    Relationship.refresh_all nil
  end
end
