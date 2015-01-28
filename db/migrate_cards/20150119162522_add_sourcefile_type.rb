# -*- encoding : utf-8 -*-

class AddSourcefileType < Wagn::Migration
  def up
    if (source = Card.fetch('Source file'))
      source.update_attributes! :type_id=>Card::CardtypeID, :codename=>'source_file'
    else
      Card.create! :name=>'Source file', :type_id=>Card::CardtypeID, :codename=>'source_file'
    end
    Card.create! :name=>'Metric', :type_id=>Card::CardtypeID, :codename=>'metric'   
    Card.create! :name=>'Source file+metric+*type plus right+*default', :type=>'pointer'
    Card.create! :name=>'Source file+metric+*type plus right+*options', :type=>'search', :content=>'{"type":"metric"}'
    Card.create! :name=>'Source file+metric+*type plus right+*input',  :content=>'[[select]]'
    
    year = Card.fetch "year"
    year.update_attributes! :codename=>'year'
    Card.create! :name=>'Source file+year*type plus right+*default', :type=>'pointer'
    Card.create! :name=>'Source file+year*type plus right+*options', :type=>'search', :content=>'{"type":"year"}'
    Card.create! :name=>'Source file+year*type plus right+*input', :content=>'[[list]]'
  end
end

