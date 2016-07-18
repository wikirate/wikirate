# -*- encoding : utf-8 -*-

class ImportUxImprovements < Card::Migration
  def up
    import_cards 'ux_improvements.json'
  end
end
