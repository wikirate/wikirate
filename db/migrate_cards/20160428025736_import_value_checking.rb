# -*- encoding : utf-8 -*-

class ImportValueChecking < Card::Migration
  def up
    import_json 'value_checking.json'
  end
end
