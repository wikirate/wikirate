# -*- encoding : utf-8 -*-

class ImportHomeAndCompanyRepairs < Card::Migration
  def up
    import_json "home_and_company_repairs.json"
  end
end
