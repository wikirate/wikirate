# -*- encoding : utf-8 -*-

class CorrectProjectCodename < Card::Migration
  def up
    project_card = Card[:campaign]
    project_card.codename = "project"
    project_card.save!
  end
end
