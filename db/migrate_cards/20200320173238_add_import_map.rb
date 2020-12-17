# -*- encoding : utf-8 -*-

class AddImportMap < Cardio::Migration
  def up
    ensure_code_card "import map"
  end
end
