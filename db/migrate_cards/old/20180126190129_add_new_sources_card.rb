# -*- encoding : utf-8 -*-

class AddNewSourcesCard < Cardio::Migration
  def up
    ensure_card "new sources", codename: "new_sources"
  end
end
