# -*- encoding : utf-8 -*-

class ImportLotsOfHelpText < Card::Migration
  def up
    import_json 'lots_of_help_text.json'
  end
end
