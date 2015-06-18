# -*- encoding : utf-8 -*-

class CodenameForHomepage < Card::Migration
  def up
    Card['home'].update_attributes! :codename=>:home
  end
end
