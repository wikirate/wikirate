# -*- encoding : utf-8 -*-

class ClaimSearch < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      Card.create! :name=>"claim search", :codename=>:claim_search, :type_code=>:search_type
    end
  end
end
