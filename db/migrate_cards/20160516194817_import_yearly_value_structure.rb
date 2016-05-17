# -*- encoding : utf-8 -*-

class ImportYearlyValueStructure < Card::Migration
  def up
    import_cards "yearly_value_structure.json"
  end
end
