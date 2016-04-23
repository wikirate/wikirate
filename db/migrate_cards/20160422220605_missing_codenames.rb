# -*- encoding : utf-8 -*-

class MissingCodenames < Card::Migration
  def up
    update_card 'unit', codename: 'unit'
    update_card 'value options', codename: 'value_options'
    update_card 'Currency', codename: 'currency'
    update_card 'aliases', codename: 'aliases'
  end
end
