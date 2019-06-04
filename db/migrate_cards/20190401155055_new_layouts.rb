# -*- encoding : utf-8 -*-

class NewLayouts < Card::Migration
  def up
    delete_code_card :wikirate_layout
    delete_code_card :wikirate_two_column_layout
  end
end
