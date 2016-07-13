# -*- encoding : utf-8 -*-

class CorrectProjectCodename < Card::Migration
  def up
    Card[:campaign].update_attributes! codename: "project"
  end
end
