# -*- encoding : utf-8 -*-

class DirectContributions < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      Card.create! :name=>"*direct contribution count", :codename=>:direct_contribution_count, :type_code=>:number, :content=>"0"
    end
  end
end
