# -*- encoding : utf-8 -*-

class ImportCiteButtonScss < Wagn::Migration
  def up
    import_json "cite_button_scss.json"
    
  end
end
