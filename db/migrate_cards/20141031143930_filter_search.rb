# -*- encoding : utf-8 -*-

class FilterSearch < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
       Card.create! :name=>"filter search", :codename=>:filter_search, :type_code=>:search_type
    end
  end
end
