# -*- encoding : utf-8 -*-

class ImportMobileAndHomePagePolish < Card::Migration
  def up
    import_json "mobile_and_home_page_polish.json"
    
  end
end
