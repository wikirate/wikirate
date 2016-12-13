# -*- encoding : utf-8 -*-

class ImportNumericValueStructure < Card::Migration
  def up
    import_cards 'numeric_value_structure.json'
  end
end
