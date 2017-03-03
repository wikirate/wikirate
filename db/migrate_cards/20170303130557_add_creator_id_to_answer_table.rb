# -*- encoding : utf-8 -*-

class AddCreatorIdToAnswerTable < ActiveRecord::Migration
  def up
    add_column :answers, :creator_id, :integer
  end
end
