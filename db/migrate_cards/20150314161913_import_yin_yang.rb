# -*- encoding : utf-8 -*-

class ImportYinYang < Card::Migration
  def up
    import_json "yinyang.json"
    #Card.create! :name=>"Oxfam spreadsheet 2014", :codename=>'oxfam_spreadsheet', :type=>'file', :attach=>File.new(data_path('oxfam-scorecard-2014.xlsx')),
    # :subcards=>{'+*self+*read'=> {:content=>"[[Administrator]]", :type=>'pointer'}}
  end
end
