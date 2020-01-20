# -*- encoding : utf-8 -*-

class ImportNewProjectStatus < Card::Migration
  def up
    import_cards 'new_project_status.json'
  end
end
