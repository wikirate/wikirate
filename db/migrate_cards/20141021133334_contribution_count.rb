# -*- encoding : utf-8 -*-

class ContributionCount < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      Card.create! :name=>"*contribution count", :codename=>:contribution_count, :type_code=>:number, :content=>"0"
    end
  end
end
