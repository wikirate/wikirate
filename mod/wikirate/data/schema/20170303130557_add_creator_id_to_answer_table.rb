# -*- encoding : utf-8 -*-

class AddCreatorIdToAnswerTable < Cardio::Migration::Schema
  def up
    add_column :answers, :creator_id, :integer
  end
end
