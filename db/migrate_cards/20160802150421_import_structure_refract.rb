# -*- encoding : utf-8 -*-

class ImportStructureRefract < Card::Migration
  def up
    import_cards 'structure_refract.json'
  end
end
