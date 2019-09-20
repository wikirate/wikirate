# -*- encoding : utf-8 -*-

class AddCompanyGroups < Card::Migration
  def up
    ensure_code_card "Company Group", type_id: Card::CardtypeID
    ensure_code_card "specification"
  end
end
