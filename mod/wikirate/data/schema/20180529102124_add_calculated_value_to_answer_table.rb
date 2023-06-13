# -*- encoding : utf-8 -*-

class AddCalculatedValueToAnswerTable < Cardio::Migration::Schema
  def up
    add_column :answers, :overridden_value, :string
  end
end
