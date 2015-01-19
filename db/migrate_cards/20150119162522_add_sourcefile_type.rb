# -*- encoding : utf-8 -*-

class AddSourcefileType < Wagn::Migration
  def up
    Card.create! :name=>'Source file', :type_id=>Card::CardtypeID, :codename=>'source_file'
  end
end
