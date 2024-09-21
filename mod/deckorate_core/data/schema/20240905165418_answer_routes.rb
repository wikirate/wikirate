# -*- encoding : utf-8 -*-

class AnswerRoutes < Cardio::Migration::Schema
  def up
    add_column :answers, :route, :integer, limit: 1
    add_column :relationships, :route, :integer, limit: 1

    add_column :relationships, :editor_id, :integer
    add_column :relationships, :created_at, :datetime
    add_column :relationships, :creator_id, :integer
  end
end
