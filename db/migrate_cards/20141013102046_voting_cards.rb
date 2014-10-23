# -*- encoding : utf-8 -*-

class VotingCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      Card.create! :name=>"*upvote count", :codename=>:upvote_count, :type_code=>:number, :content=>"0"
      Card.create! :name=>"*downvote count", :codename=>:downvote_count, :type_code=>:number, :content=>"0"
      Card.create! :name=>"*vote count", :codename=>:vote_count, :type_code=>:number, :content=>"0"

      Card.create! :name=>"*upvotes", :codename=>:upvotes, :type_code=>:pointer
      Card.create! :name=>"*downvotes", :codename=>:downvotes, :type_code=>:pointer

      Card.create! :name=>"*upvotes+*right+*default", :type_code=>:pointer
      Card.create! :name=>"*downvotes+*right+*default", :type_code=>:pointer
    end
  end
end
