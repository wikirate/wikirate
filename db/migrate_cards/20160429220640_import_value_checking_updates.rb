# -*- encoding : utf-8 -*-

class ImportValueCheckingUpdates < Card::Migration
  def up
    import_json 'value_checking_updates.json'
  end
end
