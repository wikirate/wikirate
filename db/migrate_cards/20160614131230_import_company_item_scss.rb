# -*- encoding : utf-8 -*-

class ImportCompanyItemScss < Card::Migration
  def up
    import_cards 'company_item_scss.json'
  end
end
