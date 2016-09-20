# -*- encoding : utf-8 -*-

class ImportAllValuesUpdate < Card::Migration
  def up
    import_cards 'all_values_update.json'
    delete_code_card :all_values
  end
end
