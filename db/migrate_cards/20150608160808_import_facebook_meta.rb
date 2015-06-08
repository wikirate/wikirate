# -*- encoding : utf-8 -*-

class ImportFacebookMeta < Card::Migration
  def up
    import_json "facebook_meta.json"
    
  end
end
