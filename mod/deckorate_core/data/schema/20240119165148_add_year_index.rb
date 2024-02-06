# -*- encoding : utf-8 -*-

class AddYearIndex < Cardio::Migration::Schema
  def up
    add_index :answers, :year, name: "year_index"
  end
end
