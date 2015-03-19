# -*- encoding : utf-8 -*-

class ImportNewSourceTypeAndSetPattern < Card::Migration
  def up
    Card.create! :name=>"TextSource", :type_id=>Card::CardtypeID, :codename=>"text_source"
    
    Card.create! :name=>'Citable', :type_id=>Card::SetID, :codename=>'citable' 
      ,:content=>%{
        {
          "type":["in","SourceFile","Page","TextSource"]
        }
      }
    
  end
end

