# -*- encoding : utf-8 -*-

class DirectContributions < Wagn::Migration
  def up
    Card.create! :name=>"*direct contribution count", :codename=>:direct_contribution_count, :type_code=>:number, :content=>"0"
  end
end
