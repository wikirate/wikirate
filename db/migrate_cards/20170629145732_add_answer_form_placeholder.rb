# -*- encoding : utf-8 -*-

class AddAnswerFormPlaceholder < Card::Migration
  def up
    ensure_card "replace with year", codename: "replace_with_year"
    ensure_card "replace with company", codename: "replace_with_company"
  end
end
