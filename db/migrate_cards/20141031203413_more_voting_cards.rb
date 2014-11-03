# -*- encoding : utf-8 -*-

class MoreVotingCards < Wagn::Migration
  def up
    import_json 'voting.json'
  end
end
