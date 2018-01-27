# -*- encoding : utf-8 -*-

class AddNewSourcesCard < Card::Migration
  def up
    ensure_card "new sources", codename: "new_sources"
  end
end
