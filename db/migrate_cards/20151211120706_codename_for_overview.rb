# -*- encoding : utf-8 -*-

class CodenameForOverview < Card::Migration
  def up
    Card['overview'].update_attributes! codename: 'overview'
  end
end
