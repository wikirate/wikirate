# -*- encoding : utf-8 -*-

class ImportOxfamData < Wagn::Migration
  def up
    Card.create! :name=>"Oxfam spreadsheet 2014", :codename=>'oxfam_spreadsheet', :type=>'file', :attach=>data_path('oxfam-scorecard-2014.xlsx')
  end
end
