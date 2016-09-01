# -*- encoding : utf-8 -*-

class ImportUpdateProjectStructure < Card::Migration
  def up
    import_cards 'update_project_structure.json'
  end
end
