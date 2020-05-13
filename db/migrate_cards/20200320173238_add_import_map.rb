# -*- encoding : utf-8 -*-

class AddImportMap < Card::Migration
  def up
    ensure_code_card "import map"
  end
end
