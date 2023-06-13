# -*- encoding : utf-8 -*-

class AddCalculatingFlag < Cardio::Migration::Schema
  def up
    add_column :answers, :calculating, :boolean
  end
end
