# -*- encoding : utf-8 -*-

class MoreVotingCards < ActiveRecord::Migration
  include Wagn::MigrationHelper
  def up
    contentedly do
      filename = 'voting.json'
      raw_json = File.read File.join( Wagn.root, "db/json/#{filename}" )
      json = JSON.parse raw_json
      Card.merge_list json["card"]["value"], :output_file=>"/tmp/unmerged_#{ filename }"
    end
  end
end
