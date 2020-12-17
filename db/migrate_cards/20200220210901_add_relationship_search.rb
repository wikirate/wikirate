# -*- encoding : utf-8 -*-

class AddRelationshipSearch < Cardio::Migration
  def up
    ensure_code_card "relationship_search"
  end
end
