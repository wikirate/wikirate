# -*- encoding : utf-8 -*-

class ImportRenamingInitiative < Card::Migration
  def up
    old_project_card = Card['project']
    old_project_card.name = 'Old Project'
    old_project_card.save!

    old_project_card = Card[:campaign]
    old_project_card.name = 'Project'
    old_project_card.save!

    import_json 'renaming_initiative.json'
  end
end
