# -*- encoding : utf-8 -*-

class ImportCiteButtonScss < Card::Migration
  def up
    import_json "cite_button_scss.json"
  end
end
