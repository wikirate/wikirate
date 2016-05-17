# -*- encoding : utf-8 -*-

class ImportCompanyHeader < Card::Migration
  def up
    import_json "company_header.json"
  end
end
